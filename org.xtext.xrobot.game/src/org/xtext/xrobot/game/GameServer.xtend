package org.xtext.xrobot.game

import com.google.inject.Guice
import com.google.inject.Inject
import com.google.inject.Module
import com.google.inject.Provider
import java.util.List
import javafx.application.Application
import javafx.scene.text.Font
import javafx.stage.Stage
import javafx.util.Duration
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.eclipse.xtext.xbase.XbaseStandaloneSetup
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ranking.RankingSystem

import static org.xtext.xrobot.game.PlayerStatus.*

import static extension javafx.util.Duration.*

class GameServer extends Application {
	
	static val GAME_DURATION = 1000l * 45   // 45 seconds

	static val LOG = Logger.getLogger(GameServer)
	
	public static Module gameModule = new XRobotModule
	
	def static void main(String[] args) {
		launch(args)
	}
	
	@Inject PlayerSlot.Factory playerSlotFactory
	
	@Inject IScriptPoller scriptPoller
	
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	
	@Inject RankingSystem rankingSystem

	@Accessors(PUBLIC_GETTER)
	List<PlayerSlot> slots
	
	override init() {
		// Load fonts
		Font.loadFont(class.getResourceAsStream('/fonts/flipside.ttf'), 24)
		Font.loadFont(class.getResourceAsStream('/fonts/Robotica.ttf'), 24)
		
		// Xtext initialization and dependency injection
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		XbaseStandaloneSetup.doSetup()
		val injector = Guice.createInjector(gameModule, new XRobotDSLRuntimeModule)
		new XRobotDSLStandaloneSetup().register(injector)
		injector.injectMembers(this)
		
		playerSlotFactory.display = display
		slots = playerSlotFactory.createAll
	}
	
	override start(Stage stage) throws Exception {
		display.start(stage, slots)
		scriptPoller.start(this)
	}
	
	def register(AccessToken usedToken, String script) {
		synchronized(slots) {
			val slot = slots.findFirst[matches(usedToken) && isAvailable]
			if(slot?.isAvailable) {
				try {
					slot.acquire(script)
					LOG.debug('Robot ' + slot.program.name + ' has joined the game')
				} catch (Exception exc) {
					showError(exc.message, 2.seconds)
					LOG.error('Error assigning robot', exc) 
					slot.release
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
		game.gameDuration = GAME_DURATION
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