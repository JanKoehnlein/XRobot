package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import java.util.List
import javafx.stage.Stage
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ranking.RankingProvider
import org.xtext.xrobot.game.ranking.RankingSystem
import org.xtext.xrobot.game.ui.GameControlWindow

import static org.xtext.xrobot.RobotID.*
import static org.xtext.xrobot.game.PlayerStatus.*

import static extension javafx.util.Duration.*

@Singleton
class GameServer {

	static val LOG = Logger.getLogger(GameServer)
	
	@Inject PlayerSlot.Factory playerSlotFactory
	
	@Inject IScriptPoller scriptPoller
			
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	
	@Inject RankingSystem rankingSystem

	@Inject RankingProvider rankingProvider
	
	@Inject GameControlWindow controlWindow

	@Accessors(PUBLIC_GETTER)
	List<PlayerSlot> slots
		
	def start(Stage stage) throws Exception {
		slots = playerSlotFactory.createAll
		display.start(stage, slots)
		val controlStage = new Stage
		controlWindow.start(controlStage, slots)
		controlStage.onCloseRequest = [
			stage.close
		]
		scriptPoller.start()
	}
	
	def register(AccessToken usedToken, String uri, String script) {
		synchronized(slots) {
			val slot = slots.findFirst[matches(usedToken) && isAvailable]
			if (slot?.available) {
				try {
					slot.acquire(uri, script)
					LOG.debug('Robot ' + slot.program.name + ' has joined the game')
				} catch (Exception exc) {
					display.showError('Program refused:\n' + exc.message, 5.seconds)
					LOG.error('Error assigning robot', exc)
					slot.release
				}
			}
			if (slots.forall[!available])
				startGame
		}
	}
	
	def void startGame() {
		var GameResult result
		var gamePlayed = false
		do {
			result = null
			val game = gameProvider.get()
			
			controlWindow.prepareGame(game)
			var boolean ready
			var boolean abort
			do {
				slots.forEach[prepare]
				ready = slots.forall[waitReady]
				abort = slots.exists[available]
			} while (!abort && !ready)
			
			// The slots may have been released during preparation
			for (slot : slots) {
				synchronized (slot) {
					if (slot.status == READY)
						slot.status = FIGHTING
				}
			}
			
			if (slots.forall[status == FIGHTING]) {
				display.aboutToStart(game)
				controlWindow.gameStarted(game)
				game.play(slots)
				result = evaluateGame(game)
				controlWindow.gameFinished(game)
				gamePlayed = true
			}
			
		} while(result != null && result.replay)
		if (gamePlayed) {
			LOG.debug('Releasing player slots')
			slots.forEach[release]
		} else {
			slots.forEach[if (!available) prepare]
		}
		display.startIdleProgram
	}
	
	private def evaluateGame(Game game) {
		var hasShownResult = false
		var inGameRefereeResult = game.refereeResult
		if (inGameRefereeResult == null || inGameRefereeResult.canceled) {
			// show preliminary result, don't apply until referee's veto time has expired
			val gameResult = game.gameResult
			if(inGameRefereeResult?.canceled) {
				display.showError(game.refereeResult.cancelationReason, 10.seconds)
			} else if(gameResult.canceled) {
				display.showError(game.gameResult.cancelationReason, 10.seconds)
			} else if(gameResult.isDraw) {
				display.showMessage('A Draw', 'draw', 10.seconds)
				slots.forEach[ status = DRAW ]
			} else {
				val winnerSlot = slots.findFirst[robotID == gameResult.winner]
				winnerSlot.status = WINNER
				val loserSlot = slots.findFirst[robotID == gameResult.loser]
				loserSlot.status = LOSER
				display.showMessage(winnerSlot.scriptName + ' Wins', winnerSlot.robotID.name.toLowerCase + 'wins', 10.seconds)
			}
			hasShownResult = true
			// poll referee result
			for(var i=0; i<100 && (game.refereeResult == inGameRefereeResult); i++) 
				Thread.sleep(100)
		}
		val isRefereeOverrule = game.refereeResult != null && game.refereeResult != game.gameResult
				&& !game.refereeResult.canceled
		val showResultAgain = !hasShownResult || isRefereeOverrule
		val infoPrefix = if(isRefereeOverrule)
				'Referee overrule:\n'
			else
				''
		val finalResult = game.refereeResult ?: game.gameResult
		// apply final result
		if(finalResult.isReplay) {
			if(showResultAgain)
				display.showWarning(infoPrefix + 'Replay Game', 7.seconds)
		} else if(finalResult.isCanceled) {
			if(showResultAgain)
				display.showError(finalResult.cancelationReason, 7.seconds)
		} else if(finalResult.isDraw) {
			if(showResultAgain)
				display.showMessage(infoPrefix + 'A Draw', 'draw', 7.seconds)
			slots.forEach[ status = DRAW ]
			rankingSystem.addDraw(slots.head.program, slots.last.program)
		} else {
			val winnerSlot = slots.findFirst[robotID == finalResult.winner]
			winnerSlot.status = WINNER
			val loserSlot = slots.findFirst[robotID == finalResult.loser]
			loserSlot.status = LOSER
			if(showResultAgain)
				display.showMessage(infoPrefix + winnerSlot.scriptName + ' Wins', winnerSlot.robotID.name.toLowerCase + 'wins', 7.seconds)
			rankingSystem.addWin(winnerSlot.program, loserSlot.program)
		}
		if(!finalResult.canceled) {
			rankingProvider.setBlueAndRed(
				slots.findFirst[robotID==Blue]?.program, 
				slots.findFirst[robotID==Red]?.program
			)
		} else {
			rankingProvider.setBlueAndRed(null, null)
		}
		if(showResultAgain)
			Thread.sleep(7000)
		return finalResult
	}
	
}
