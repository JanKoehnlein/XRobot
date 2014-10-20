package org.xtext.xrobot.game.ui

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.List
import javafx.application.Platform
import javafx.geometry.Insets
import javafx.geometry.Orientation
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.layout.TilePane
import javafx.scene.layout.VBox
import javafx.stage.Stage
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.GameServer
import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.game.example.ExampleRobot

import static javafx.scene.layout.Region.*
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
		stage.title = 'Game control'
		stage.scene = new Scene(createRoot(), 640, 480)
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
			val blue = slots.findFirst[robotID == Blue]
			val red = slots.findFirst[robotID == Red]
			children += new TilePane => [
				minWidth = USE_PREF_SIZE
				orientation = Orientation.VERTICAL
				hgap = 20
				vgap = 10
				prefRows = 4
				children += new Label('Blue')
				children += chooseBlueCombo = createExampleCombo(blue) => [
					slotButtons += it
					minWidth = USE_PREF_SIZE
					maxWidth = Double.MAX_VALUE
				]
				children += expungeBlueButton = new Button('Expunge') => [
					slotButtons += it
					onAction = [
						synchronized (blue) {
							if (!#{FIGHTING, WINNER, LOSER, DRAW}.contains(blue.status)) {
								chooseBlueCombo.selectionModel.select(null)
								blue.release
							}
						}
					]
					minWidth = USE_PREF_SIZE
					maxWidth = Double.MAX_VALUE
				]
				children += placeBlueButton = new Button('Place') => [
					slotButtons += it
					onAction = [
						if (#{NOT_AT_HOME, AVAILABLE}.contains(blue.status))
							blue.prepare
					]
					minWidth = USE_PREF_SIZE
					maxWidth = Double.MAX_VALUE
				]
				children += new Label('Red')
				children += chooseRedCombo = createExampleCombo(red) => [
					slotButtons += it
					minWidth = USE_PREF_SIZE
					maxWidth = Double.MAX_VALUE
				]
				children += expungeRedButton = new Button('Expunge') => [
					slotButtons += it
					onAction = [
						synchronized (red) {
							if (!#{FIGHTING, WINNER, LOSER, DRAW}.contains(red.status)) {
								chooseRedCombo.selectionModel.select(null)
								red.release
							}
						}
					]
					minWidth = USE_PREF_SIZE
					maxWidth = Double.MAX_VALUE
				]
				children += placeRedButton = new Button('Place') => [
					slotButtons += it
					onAction = [
						if (#{NOT_AT_HOME, AVAILABLE}.contains(red.status))
							red.prepare
					]
					minWidth = USE_PREF_SIZE
					maxWidth = Double.MAX_VALUE
				]
			]
			children += new Separator
			children += new Label('Referee')
			children += refereeButtons = new HBox => [
				spacing = 10
				children += new Button('Blue wins') => [
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
				children += new Button('Red wins') => [
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
						gameServer.register(
							slot.token,
							example.URI,
							example.code
						)
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
