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
		game.play(slots)
		if(game.exception != null) {
			if(display.askRepeat(game.exception)) 
				startGame
		} else {
			val infoPrefix = if(game.isIsCanceledByReferee)
					'Referee decision:\n'
				else 
					''
			if(game.loser != null) {
				val winnerSlot = slots.findFirst[robotID != game.loser]
				winnerSlot.status = WINNER
				val loserSlot = slots.findFirst[robotID == game.loser]
				loserSlot.status = LOSER
				display.showInfo(infoPrefix + winnerSlot.scriptName + ' wins')
				rankingSystem.addWin(winnerSlot.scriptName, loserSlot.scriptName)
			} else {
				display.showInfo(infoPrefix + 'Nobody won')
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
	
}