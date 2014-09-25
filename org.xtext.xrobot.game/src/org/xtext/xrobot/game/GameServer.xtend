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

	List<PlayerSlot> slots 
	
	new() {
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration.injectMembers(this)
		slots = #[new PlayerSlot(RobotID.Xtend, remoteRobotConnector), new PlayerSlot(RobotID.Xtext, remoteRobotConnector)]
	}
	
	override start(Stage stage) throws Exception {
		display.start(stage, slots)
		new Thread[
			Thread.sleep(1000)
			register(slots.get(0).token, '''
				robot Dancer
				author Jan
				
				Dance {
					rotateSpeed = maxRotateSpeed * 0.3
					rotateLeft
					while(true) {
						scoop(1)
						scoop(0)
					}
				}
			''')
			register(slots.get(1).token, '''
				robot bar
				author bar
				
				Foo {
					rotate(-20)
				}
			''')
		].start
	}
	
	def register(AccessToken usedToken, String script) {
		synchronized(slots) {
			val slot = slots.findFirst[matches(token) && isAvailable]
			if(slot?.isAvailable) {
				val resourceSet = resourceSetProvider.get
				val program = scriptParser.parse(script, resourceSet)
				if(program != null) {
					slot.acquire(program)
					slot.placeRobot					
				}
			}	
		}
		if(slots.forall[!isAvailable])
			startGame
	}
	
	def void startGame() {
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