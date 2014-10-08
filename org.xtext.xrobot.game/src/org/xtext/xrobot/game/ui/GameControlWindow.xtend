package org.xtext.xrobot.game.ui

import com.google.inject.Singleton
import java.util.List
import javafx.application.Platform
import javafx.geometry.Insets
import javafx.scene.Scene
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.PlayerSlot

import static org.xtext.xrobot.RobotID.*
import static org.xtext.xrobot.game.GameResult.*
import static org.xtext.xrobot.game.PlayerStatus.*

@Singleton
class GameControlWindow implements IGameListener {

	Pane slotButtons
	Pane preparationButtons
	Pane refereeButtons

	Game currentGame
	
	List<PlayerSlot> slots
	
	Button placeBlueButton
	
	Button placeRedButton
	
	Button releaseBlueButton
	
	Button releaseRedButton

	override start(Stage stage, List<PlayerSlot> slots) {
		this.slots = slots
		stage.title = 'Game control'
		stage.scene = new Scene(createRoot(), 640, 480)
		stage.show
		addSlotListener(Blue, releaseBlueButton, placeBlueButton)
		addSlotListener(Red, releaseRedButton, placeRedButton)
	}
	
	private def addSlotListener(RobotID robotID, Button releaseButton, Button placeButton) {
		val slot = slots.findFirst[it.robotID == robotID]
		slot.addSlotListener [
			Platform.runLater [
				switch slot.status {
					case NOT_AT_HOME,
					case AVAILABLE:
						placeButton.disable = false
					default:
						placeButton.disable = true
				}
				releaseButton.disable = (slot.status == AVAILABLE)
			]
		]
		
	}

	def createRoot() {
		new VBox => [
			spacing = 10
			padding = new Insets(10)
			children += new Label('Slots')
			children += slotButtons = new HBox => [
				spacing = 10
				children += releaseBlueButton = new Button('Expunge Blue') => [
					onAction = [
						slots.findFirst[robotID == Blue].release
					]
				]
				children += releaseRedButton = new Button('Expunge Red') => [
					onAction = [
						slots.findFirst[robotID == Red].release
					]
				]
			]
			children += new Separator
			children += new Label('Preparation')
			children += preparationButtons = new HBox => [
				spacing = 10
				children += placeBlueButton = new Button('Place Blue') => [
					onAction = [
						slots.findFirst[robotID == Blue].ready
					]
				]
				children += placeRedButton = new Button('Place Red') => [
					onAction = [
						slots.findFirst[robotID == Red].ready
					]
				]
			]
			children += new Separator
			children += new Label('Referee')
			children += refereeButtons = new HBox => [
				spacing = 10
				children += new Button('Blue wins') => [
					onAction = [
						currentGame.refereeResult = win(Blue)
					]
				]
				children += new Button('Draw') => [
					onAction = [
						currentGame.refereeResult = draw
					]
				]
				children += new Button('Red wins') => [
					onAction = [
						currentGame.refereeResult = win(Red)
					]
				]
				children += new Button('Cancel') => [
					onAction = [
						currentGame.refereeResult = canceled('Canceled by Referee')
					]
				]
				children += new Button('Replay') => [
					onAction = [
						currentGame.refereeResult = replay
					]
				]
				disable = true
			]
		]
	}

	override gameStarted(Game game) {
		Platform.runLater [
			slotButtons.disable = true
			currentGame = game
			refereeButtons.disable = false
		]
	}

	override gameFinished(Game game) {
		Platform.runLater [
			currentGame = null
			refereeButtons.disable = true
			slotButtons.disable = false
		]
	}
}
