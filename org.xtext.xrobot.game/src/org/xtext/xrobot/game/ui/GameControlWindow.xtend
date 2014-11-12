package org.xtext.xrobot.game.ui

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.List
import javafx.application.Platform
import javafx.geometry.Insets
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.layout.GridPane
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.GameServer
import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.game.demo.ExampleRobot

import static org.xtext.xrobot.RobotID.*
import static org.xtext.xrobot.game.GameResult.*
import static org.xtext.xrobot.game.PlayerStatus.*

@Singleton
class GameControlWindow implements IGameListener {

	@Inject ExampleRobot.Provider exampleProvider
	@Inject GameServer gameServer
	
	List<Node> slotButtons = newArrayList
	
	Pane refereeButtons

	Game currentGame
	
	List<PlayerSlot> slots
	
	ComboBox<ExampleRobot> chooseBlueCombo

	ComboBox<ExampleRobot> chooseRedCombo

	Button placeBlueButton
	
	Button placeRedButton
	
	Button expungeBlueButton
	
	Button expungeRedButton
	

	override start(Stage stage, List<PlayerSlot> slots) {
		this.slots = slots
		stage.title = 'Game Control'
		stage.scene = new Scene(createRoot())
		stage.resizable = false
		stage.show
		addSlotListener(Blue, chooseBlueCombo, expungeBlueButton, placeBlueButton)
		addSlotListener(Red, chooseRedCombo, expungeRedButton, placeRedButton)
	}
	
	private def addSlotListener(RobotID robotID, ComboBox<ExampleRobot> chooseCombo, Button expungeButton, Button placeButton) {
		val slot = slots.findFirst[it.robotID == robotID]
		val PlayerSlot.Listener listener = [
			Platform.runLater [
				placeButton.disable = !#{NOT_AT_HOME, AVAILABLE}.contains(slot.status)
				expungeButton.disable = slot.isAvailable || #{FIGHTING, WINNER, LOSER, DRAW}.contains(slot.status) 
				chooseCombo.disable = !slot.isAvailable
			]
		]
		listener.slotChanged
		slot.addSlotListener(listener)
	}

	def createRoot() {
		new VBox => [
			spacing = 10
			padding = new Insets(10)
			children += new HBox => [
				spacing = 10
				children += new Button('Start Demo Mode') => [ button |
					button.onAction = [
						if (gameServer.demoModeActive) {
							gameServer.stopDemoMode
							button.text = 'Start Demo Mode'
						} else {
							gameServer.startDemoMode
							button.text = 'Stop Demo Mode'
						}
					]
				]
			]
			children += new Separator
			val blue = slots.findFirst[robotID == Blue]
			val red = slots.findFirst[robotID == Red]
			children += new GridPane => [
				hgap = 20
				vgap = 10
				add(new Label('Blue'), 0, 0)
				add(chooseBlueCombo = createExampleCombo(blue) => [
					slotButtons += it
					setMaxWidth(Double.MAX_VALUE)
				], 0, 1)
				add(expungeBlueButton = new Button('Expunge') => [
					slotButtons += it
					onAction = [
						synchronized (blue) {
							if (!#{FIGHTING, WINNER, LOSER, DRAW}.contains(blue.status)) {
								chooseBlueCombo.selectionModel.select(null)
								blue.release
							}
						}
					]
					setMaxWidth(Double.MAX_VALUE)
				], 0, 2)
				add(placeBlueButton = new Button('Place') => [
					slotButtons += it
					onAction = [
						if (#{NOT_AT_HOME, AVAILABLE}.contains(blue.status)) {
							new Thread([
								blue.prepare
							], 'Robot Preparer') => [
								daemon = true
								start
							]
						}
					]
					setMaxWidth(Double.MAX_VALUE)
				], 0, 3)
				add(new Label('Red'), 1, 0)
				add(chooseRedCombo = createExampleCombo(red) => [
					slotButtons += it
					setMaxWidth(Double.MAX_VALUE)
				], 1, 1)
				add(expungeRedButton = new Button('Expunge') => [
					slotButtons += it
					onAction = [
						synchronized (red) {
							if (!#{FIGHTING, WINNER, LOSER, DRAW}.contains(red.status)) {
								chooseRedCombo.selectionModel.select(null)
								red.release
							}
						}
					]
					setMaxWidth(Double.MAX_VALUE)
				], 1, 2)
				add(placeRedButton = new Button('Place') => [
					slotButtons += it
					onAction = [
						if (#{NOT_AT_HOME, AVAILABLE}.contains(red.status)) {
							new Thread([
								red.prepare
							], 'Robot Preparer') => [
								daemon = true
								start
							]
						}
					]
					setMaxWidth(Double.MAX_VALUE)
				], 1, 3)
			]
			children += new Separator
			children += new Label('Referee')
			children += refereeButtons = new HBox => [
				spacing = 10
				children += new Button('Blue Wins') => [
					onAction = [
						if (currentGame != null)
							currentGame.refereeResult = win(Blue)
					]
				]
				children += new Button('Draw') => [
					onAction = [
						if (currentGame != null)
							currentGame.refereeResult = draw
					]
				]
				children += new Button('Red Wins') => [
					onAction = [
						if (currentGame != null)
							currentGame.refereeResult = win(Red)
					]
				]
				children += new Button('Cancel') => [
					onAction = [
						if (currentGame != null)
							currentGame.refereeResult = canceled('Canceled by Referee')
					]
				]
				children += new Button('Replay') => [
					onAction = [
						if (currentGame != null)
							currentGame.refereeResult = replay
					]
				]
				disable = true
			]
		]
	}
	
	private def createExampleCombo(PlayerSlot slot) {
		new ComboBox => [ cb |
			cb.items += exampleProvider.exampleRobots
			cb.onAction = [
				val example = cb.selectionModel.selectedItem
				if (example != null && slot.available) {
					new Thread([
						gameServer.register(slot.token, example.URI, example.code, false)
						// Registration may fail if the camera image is not available
						if (slot.available)
							Platform.runLater [ cb.selectionModel.select(null) ]
					], 'Example Robot Chooser') => [
						daemon = true
						start
					]
				}
			]
		]
	}

	override prepareGame(Game game) {
		Platform.runLater [
			slotButtons.forEach[disable = true]
			currentGame = game
		]
	}
	
	override gameStarted(Game game) {
		Platform.runLater [
			refereeButtons.disable = false
		]
	}

	override gameFinished(Game game) {
		Platform.runLater [
			currentGame = null
			chooseBlueCombo.selectionModel.select(null)
			chooseRedCombo.selectionModel.select(null)
			refereeButtons.disable = true
		]
	}
}
