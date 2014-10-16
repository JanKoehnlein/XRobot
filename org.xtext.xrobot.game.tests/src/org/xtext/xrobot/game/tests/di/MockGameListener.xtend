package org.xtext.xrobot.game.tests.di

import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.Game
import javafx.stage.Stage
import java.util.List
import org.xtext.xrobot.game.PlayerSlot

class MockGameListener implements IGameListener {
	
	override prepareGame(Game game) {
		println("# game preparation")
	}

	override gameFinished(Game game) {
		println("# game finished")
	}
	
	override gameStarted(Game game) {
		println("# game started")
	}
	
	override start(Stage stage, List<PlayerSlot> slots) {
	}
}