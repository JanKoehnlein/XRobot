package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import java.util.List
import javafx.stage.Stage
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ranking.RankingSystem
import org.xtext.xrobot.game.ui.GameControlWindow

import static org.xtext.xrobot.game.PlayerStatus.*

@Singleton
class GameServer {
	
	static val GAME_DURATION = 1000l * 45   // 45 seconds

	static val LOG = Logger.getLogger(GameServer)
	
	@Inject PlayerSlot.Factory playerSlotFactory
	
	@Inject IScriptPoller scriptPoller
			
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	
	@Inject RankingSystem rankingSystem
	
	@Inject GameControlWindow controlWindow

	@Accessors(PUBLIC_GETTER)
	List<PlayerSlot> slots
		
	def start(Stage stage) throws Exception {
		slots = playerSlotFactory.createAll
		val displayStage = new Stage()
		displayStage.initOwner = stage
		display.start(displayStage, slots)
		displayStage.toBack
		controlWindow.start(stage, slots)
		scriptPoller.start()
	}
	
	def register(AccessToken usedToken, String script) {
		synchronized(slots) {
			val slot = slots.findFirst[matches(usedToken) && isAvailable]
			if(slot?.isAvailable) {
				try {
					slot.acquire(script)
					LOG.debug('Robot ' + slot.program.name + ' has joined the game')
				} catch (Exception exc) {
					display.showError(exc.message)
					LOG.error('Error assigning robot', exc) 
					slot.release
				}
			}	
		}
		if(slots.forall[!isAvailable])
			startGame
	}
	
	def void startGame() {
		while(!slots.map[waitReady; status == READY].reduce[$0 && $1]) 
			Thread.sleep(5000)
		display.prepareGame
		val game = gameProvider.get()
		game.gameDuration = GAME_DURATION
		slots.forEach[status = FIGHTING]
		controlWindow.gameStarted(game)
		game.play(slots)
		if(game.refereeResult == null) {
			// show preliminary result
			val gameResult = game.gameResult
			if(gameResult.canceled) {
				display.showError(game.gameResult.cancelationReason)
			} else if(gameResult.isDraw) {
				display.showInfo('Preliminary result:\nA draw')
			} else {
				val winnerSlot = slots.findFirst[robotID == gameResult.winner]
				display.showInfo('Preliminary result:\n' + winnerSlot.scriptName + ' wins')
			}
			for(var i=0; i<55 && game.refereeResult == null; i++) 
				Thread.sleep(100)
		}
		val infoPrefix = if(game.refereeResult != null && game.refereeResult != game.gameResult)
				'Referee overrule:\n'
			else 
				''
		val finalResult = game.refereeResult ?: game.gameResult
		if(finalResult.isCanceled) {
			display.showError(finalResult.cancelationReason)
		 } else if(finalResult.isDraw) {
			display.showInfo(infoPrefix + 'A draw')
			slots.forEach[ status = DRAW ]
			rankingSystem.addDraw(slots.head.scriptName, slots.last.scriptName)
		} else {
			val winnerSlot = slots.findFirst[robotID == finalResult.winner]
			winnerSlot.status = WINNER
			val loserSlot = slots.findFirst[robotID == finalResult.loser]
			loserSlot.status = LOSER
			display.showInfo(infoPrefix + winnerSlot.scriptName + ' wins')
			rankingSystem.addWin(winnerSlot.scriptName, loserSlot.scriptName)
		}
		controlWindow.gameFinished(game)
		LOG.debug('Releasing player slots')
		slots.forEach[release]
		Thread.sleep(5000)
		display.startIdleProgram
	}
	
}