/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import java.util.List
import javafx.scene.media.AudioClip
import javafx.stage.Stage
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.demo.DemoModeHandler
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ranking.RankingProvider
import org.xtext.xrobot.game.ranking.RankingSystem
import org.xtext.xrobot.game.ui.GameControlWindow
import org.xtext.xrobot.util.EmptyBatteriesException

import static org.xtext.xrobot.RobotID.*
import static org.xtext.xrobot.game.PlayerStatus.*

import static extension javafx.util.Duration.*

@Singleton
class GameServer {
	
	static val START_SOUND_VOLUME = 0.6
	static val WIN_SOUND_VOLUME = 0.6
	static val DRAW_SOUND_VOLUME = 0.9

	static val LOG = Logger.getLogger(GameServer)
	
	@Inject PlayerSlot.Factory playerSlotFactory
	
	@Inject IScriptPoller scriptPoller
			
	@Inject Provider<Game> gameProvider
	
	@Inject Display display
	
	@Inject RankingSystem rankingSystem

	@Inject RankingProvider rankingProvider
	
	@Inject GameControlWindow controlWindow
	
	@Inject Provider<DemoModeHandler> demoModeHandlerProvider

	@Accessors(PUBLIC_GETTER)
	List<PlayerSlot> slots
	
	AudioClip gameStartClip
	
	AudioClip gameDrawClip
	
	AudioClip gameWinClip
	
	@Accessors(PUBLIC_GETTER)
	boolean demoModeActive
	
	DemoModeHandler currentDemoHandler
	
	val demoLock = new Object
	
	def start(Stage stage) throws Exception {
		slots = playerSlotFactory.createAll
		slots.forEach[addSlotListener[handleDemoMode]]
		display.start(stage, slots)
		val controlStage = new Stage
		controlWindow.start(controlStage, slots)
		controlStage.onCloseRequest = [
			stage.close
		]
		scriptPoller.start()
		gameStartClip = new AudioClip(GameServer.getResource('/samples/boxing_bell.mp3').toString)
		gameDrawClip = new AudioClip(GameServer.getResource('/samples/buzzer.wav').toString)
		gameWinClip = new AudioClip(GameServer.getResource('/samples/fanfare.wav').toString)
	}
	
	def register(AccessToken usedToken, String uri, String script, boolean demoMode) {
		synchronized(slots) {
			val slot = slots.findFirst[matches(usedToken) && isAvailable]
			if (slot?.available) {
				try {
					slot.acquire(uri, script)
					if (LOG.debugEnabled && slot.program != null)
						LOG.debug('Robot ' + slot.program.name + ' has joined the game')
				} catch (Exception exc) {
					display.showError('Program refused on ' + slot.robotID + ' slot:\n' + exc.message, 6.seconds)
					LOG.error('Error assigning robot to slot ' + slot.robotID, exc)
					slot.release
				}
			}
			
			if (slots.forall[!available]) {
				try {
					startGame(demoMode)
				} catch (Exception exc) {
					display.showError('An error occurred', 5.seconds)
					LOG.error('Error during game execution', exc)
				}
			}
		}
	}
	
	def void startGame(boolean demoMode) {
		var GameResult result
		var gamePlayed = false
		display.demoMode = demoMode
		do {
			result = null
			val game = gameProvider.get()
			
			controlWindow.prepareGame(game)
			var boolean ready
			var boolean abort
			do {
				slots.forEach[
					try {
						prepare
					} catch (EmptyBatteriesException ebe) {
						LOG.warn(ebe.message)
					}
				]
				ready = slots.forall[waitReady]
				abort = slots.exists[available || status == BATTERY_EXHAUSTED]
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
				val volume = if (demoMode) 0.5 * START_SOUND_VOLUME else START_SOUND_VOLUME
				gameStartClip.play(volume)
				game.play(slots)
				result = evaluateGame(game, demoMode)
				controlWindow.gameFinished(game)
				gamePlayed = true
			}
			
		} while(result != null && result.replay)
		val finalGamePlayed = gamePlayed
		slots.forEach[
			if (finalGamePlayed || status == BATTERY_EXHAUSTED)
				release
			else if (!available)
				prepare
		]
		display.demoMode = false
		display.startIdleProgram
	}
	
	private def evaluateGame(Game game, boolean demoMode) {
		val drawVolume = if (demoMode) 0.5 * DRAW_SOUND_VOLUME else DRAW_SOUND_VOLUME
		val winVolume = if (demoMode) 0.5 * WIN_SOUND_VOLUME else WIN_SOUND_VOLUME
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
				gameDrawClip.play(drawVolume)
			} else {
				val winnerSlot = slots.findFirst[robotID == gameResult.winner]
				winnerSlot.status = WINNER
				val loserSlot = slots.findFirst[robotID == gameResult.loser]
				loserSlot.status = LOSER
				display.showMessage(winnerSlot.scriptName + ' Wins', winnerSlot.robotID.name.toLowerCase + 'wins', 10.seconds)
				gameWinClip.play(winVolume)
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
			if(showResultAgain) {
				display.showMessage(infoPrefix + 'A Draw', 'draw', 7.seconds)
				gameDrawClip.play(drawVolume)
			}
			slots.forEach[ status = DRAW ]
			if (!demoMode)
				rankingSystem.addDraw(slots.head.program, slots.last.program)
		} else {
			val winnerSlot = slots.findFirst[robotID == finalResult.winner]
			winnerSlot.status = WINNER
			val loserSlot = slots.findFirst[robotID == finalResult.loser]
			loserSlot.status = LOSER
			if (showResultAgain) {
				display.showMessage(infoPrefix + winnerSlot.scriptName + ' Wins', winnerSlot.robotID.name.toLowerCase + 'wins', 7.seconds)
				gameWinClip.play(winVolume)
			}
			if (!demoMode)
				rankingSystem.addWin(winnerSlot.program, loserSlot.program)
		}
		if(!finalResult.canceled && !demoMode) {
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
	
	def startDemoMode() {
		if (demoModeActive)
			throw new IllegalStateException
		demoModeActive = true
		handleDemoMode
	}
	
	def stopDemoMode() {
		if (!demoModeActive)
			throw new IllegalStateException
		demoModeActive = false
	}
	
	private def handleDemoMode() {
		synchronized (demoLock) {
			if (demoModeActive && slots.forall[available]) {
				if (currentDemoHandler == null || !currentDemoHandler.alive) {
					currentDemoHandler = demoModeHandlerProvider.get
					currentDemoHandler.start
				}
			} else if (currentDemoHandler != null) {
				currentDemoHandler.cancel = true
				currentDemoHandler = null
			}
		}
	}
	
}
