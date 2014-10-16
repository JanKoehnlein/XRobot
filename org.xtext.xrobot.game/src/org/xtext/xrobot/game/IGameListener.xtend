package org.xtext.xrobot.game

import java.util.List
import javafx.stage.Stage

interface IGameListener {
	
	def void start(Stage stage, List<PlayerSlot> slots)
	
	def void prepareGame(Game game)
	
	def void gameStarted(Game game)

	def void gameFinished(Game game)
}