package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import javafx.application.Application
import javafx.stage.Stage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.ScriptParser
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.server.testing.MockRobotConnector

class GameServer extends Application {
	
	def static void main(String[] args) {
		launch()
	}
	
//	@Inject IRemoteRobot.Connector remoteRobotConnector
	@Inject MockRobotConnector remoteRobotConnector
	@Inject Provider<XtextResourceSet> resourceSetProvider

	@Inject ScriptParser scriptParser
	
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	@Inject HallOfFameProvider hallOfFameProvider

	IRobotListener listener 
	
	List<PlayerSlot> slots 
	
	new() {
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		new XRobotDSLStandaloneSetup().createInjector.injectMembers(this)
		slots = #[new PlayerSlot(RobotID.Xtend, remoteRobotConnector), new PlayerSlot(RobotID.Xtext, remoteRobotConnector)]
	}
	
	override start(Stage stage) throws Exception {
		display.start(stage, slots)
	}
	
	def synchronized register(AccessToken usedToken, String scriptName, String script) {
		val slot = slots.findFirst[matches(token) && !isAvailable]
		if(slot?.isAvailable) {
			val resourceSet = resourceSetProvider.get
			val program = scriptParser.parse(scriptName, script, resourceSet)
			if(program != null) {
				slot.acquire(program)
				if(slots.forall[isAvailable])
					startGame
			}
		}
	}
	
	def void startGame() {
		display.prepareGame
		val game = gameProvider.get()
		display.gameStarted
		game.play(slots, listener)
		display.gameFinished
		if(game.exception != null) {
			if(display.askRepeat(game.exception)) 
				startGame
		} else {
			if(game.loser != null) {
				slots.forEach[
					if(robotID == game.loser)
						hallOfFameProvider.addDefeat(scriptName)
					else
						hallOfFameProvider.addWin(scriptName)
				]
			} else {
				slots.forEach[hallOfFameProvider.addDraw(scriptName)]
			}
			
		}
		slots.forEach[release]
		display.idle
	}
}