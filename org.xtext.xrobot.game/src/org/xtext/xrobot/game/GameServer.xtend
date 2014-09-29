package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import javafx.application.Application
import javafx.stage.Stage
import javafx.util.Duration
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.dsl.interpreter.ScriptParser
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.server.IRemoteRobot

import static extension javafx.util.Duration.*

class GameServer extends Application {

	static val LOG = Logger.getLogger(GameServer)
	
	def static void main(String[] args) {
		launch()
	}
	
	@Inject IRemoteRobot.Connector remoteRobotConnector
//	@Inject MockRobotConnector remoteRobotConnector
	@Inject Provider<XtextResourceSet> resourceSetProvider

	@Inject ScriptParser scriptParser
	
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	@Inject HallOfFameProvider hallOfFameProvider
//	@Inject MockScriptPoller scriptPoller
	@Inject ScriptPoller scriptPoller

	List<PlayerSlot> slots 
	
	new() {
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration.injectMembers(this)
		slots = #[new PlayerSlot(RobotID.Xtend, remoteRobotConnector), new PlayerSlot(RobotID.Xtext, remoteRobotConnector)]
	}
	
	override start(Stage stage) throws Exception {
		display.start(stage, slots)
		scriptPoller.start(this)
	}
	
	protected def getSlots() {
		slots
	}
	
	def register(AccessToken usedToken, String script) {
		synchronized(slots) {
			val slot = slots.findFirst[matches(usedToken) && isAvailable]
			if(slot?.isAvailable) {
				val resourceSet = resourceSetProvider.get
				val program = scriptParser.parse(script, resourceSet)
				if(program != null) {
					try {
						LOG.debug('Robot ' + program.name + ' has joined the game')
						slot.acquire(program)
						slot.preparer.getReady(display)					
					} catch (Exception exc) {
						showError(exc.message, 2.seconds)
						LOG.error('Error assigning robot', exc) 
						slot.release
					}
				}
			}	
		}
		if(slots.forall[!isAvailable])
			startGame
	}
	
	def void startGame() {
		while(!slots.map[preparer.isReady(display)].reduce[$0 && $1]) 
			Thread.sleep(5000)
		display.prepareGame
		val game = gameProvider.get()
		display.gameStarted
		game.play(slots)
		display.gameFinished
		if(game.exception != null) {
			if(display.askRepeat(game.exception)) 
				startGame
		} else {
			if(game.loser != null) {
				slots.forEach[
					if(robotID == game.loser) {
						hallOfFameProvider.addDefeat(scriptName)
					} else {
						display.showInfo(scriptName + ' wins', 2.seconds)
						hallOfFameProvider.addWin(scriptName)
					}
				]
			} else {
				display.showInfo('Draw', 2.seconds)
				slots.forEach[hallOfFameProvider.addDraw(scriptName)]
			}
		}
		LOG.debug('Releasing player slots')
		slots.forEach[release]
		display.idle
	}
	
	def void showInfo(String message, Duration duration) {
		LOG.warn(message)
		display.showInfo(message, duration)
	}
	
	def void showError(String message, Duration duration) {
		LOG.error(message)
		display.showError(message, duration)	
	}
}