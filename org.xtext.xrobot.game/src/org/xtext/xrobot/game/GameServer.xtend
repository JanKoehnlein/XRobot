package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import javafx.application.Application
import javafx.scene.text.Font
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
import org.xtext.xrobot.game.ranking.RankingSystem
import org.xtext.xrobot.server.IRemoteRobot

import static org.xtext.xrobot.game.PlayerStatus.*

import static extension javafx.util.Duration.*

class GameServer extends Application {

	static val LOG = Logger.getLogger(GameServer)
	
	def static void main(String[] args) {
		launch()
	}
	
	@Inject IRemoteRobot.Connector remoteRobotConnector
	@Inject ScriptPoller scriptPoller
//	@Inject MockRobotConnector remoteRobotConnector
//	@Inject MockScriptPoller scriptPoller
	@Inject Provider<XtextResourceSet> resourceSetProvider

	@Inject ScriptParser scriptParser
	
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	@Inject RankingSystem rankingSystem

	List<PlayerSlot> slots 
	
	new() {
		Font.loadFont(class.getResourceAsStream('/fonts/flipside.ttf'), 24)
		Font.loadFont(class.getResourceAsStream('/fonts/Robotica.ttf'), 24)
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration.injectMembers(this)
		slots = #[new PlayerSlot(RobotID.Blue, remoteRobotConnector, display), new PlayerSlot(RobotID.Red, remoteRobotConnector, display)]
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
		while(!slots.map[waitReady].reduce[$0 && $1]) 
			Thread.sleep(5000)
		display.prepareGame
		val game = gameProvider.get()
		slots.forEach[status = FIGHTING]
		display.gameStarted
		game.play(slots)
		display.gameFinished
		if(game.exception != null) {
			if(display.askRepeat(game.exception)) 
				startGame
		} else {
			if(game.loser != null) {
				val winnerSlot = slots.findFirst[robotID != game.loser]
				winnerSlot.status = WINNER
				val loserSlot = slots.findFirst[robotID == game.loser]
				loserSlot.status = LOSER
				display.showInfo(winnerSlot.scriptName + ' wins', 5.seconds)
				rankingSystem.addWin(winnerSlot.scriptName, loserSlot.scriptName)
			} else {
				display.showInfo('Nobody won', 5.seconds)
				slots.forEach[
					status = DRAW
				]
				rankingSystem.addDraw(slots.head.scriptName, slots.last.scriptName)
			}
			Thread.sleep(5000)
		}
		LOG.debug('Releasing player slots')
		slots.forEach[release]
		display.startIdleProgram
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