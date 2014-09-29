package org.xtext.xrobot.game.display

import java.util.List
import javafx.animation.Interpolator
import javafx.animation.ScaleTransition
import javafx.animation.SequentialTransition
import javafx.application.Platform
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.Scene
import javafx.scene.control.Label
import javafx.scene.layout.BorderPane
import javafx.scene.layout.StackPane
import javafx.stage.Screen
import javafx.stage.Stage
import javafx.stage.StageStyle
import javafx.util.Duration
import javax.inject.Inject
import org.xtext.xrobot.game.PlayerSlot

import static extension javafx.scene.layout.BorderPane.*
import static extension javafx.util.Duration.*
import javafx.animation.FadeTransition
import javafx.scene.layout.VBox
import javafx.scene.control.Button

class Display {

	@Inject BorderPane topLayer
	@Inject HallOfFameTable hallOfFame
	@Inject StackPane centerPane
	@Inject VBox messagePane

	List<PlayerSlotBox> slotBoxes

	def start(Stage stage, List<PlayerSlot> slots) throws Exception {
		stage => [
			initStyle(StageStyle.TRANSPARENT);
			val screenBounds = Screen.getPrimary.bounds
			scene = new Scene(
				topLayer => [
					styleClass += 'border-pane'
					center = centerPane => [
						children += hallOfFame
						children += messagePane => [
							styleClass += 'message-pane'
						]
						alignment = Pos.CENTER
					]
					val xtendBox = new PlayerSlotBox(slots.head)
					val xtextBox = new PlayerSlotBox(slots.last)
					slotBoxes = #[xtendBox, xtextBox]
					left = xtendBox
					xtendBox.alignment = Pos.CENTER
					xtendBox.margin = new Insets(20)
					right = xtextBox
					xtextBox.alignment = Pos.CENTER
					xtextBox.margin = new Insets(20)
				], screenBounds.width, screenBounds.height) => [
				fill = null
				stylesheets += 'org/xtext/xrobot/game/display/Styles.css'
			]
			show
		]
		idle
	}

	def prepareGame() {
		Platform.runLater[
			hallOfFame.hide
			countdown()
		]
	}

	def countdown() {
		val label = new Label('Ready') => [
			styleClass += 'countdown'
		]
		centerPane.children += label
		new SequentialTransition => [
			children += getPopupTransition(label, 'Steady')
			children += getPopupTransition(label, 'Go!')
			children += getPopupTransition(label, '')
			onFinished = [
				centerPane.children -= label
			]
			play
		]
	}

	private def getPopupTransition(Label label, String nextText) {
		new ScaleTransition => [
			fromX = 0.1
			toX = 10
			fromY = 0.1
			toY = 10
			node = label
			duration = 1.seconds
			interpolator = Interpolator.EASE_OUT
			onFinished = [
				label => [
					scaleX = 0.1
					scaleY = 0.1
					label.text = nextText
				]
			]
		]
	}

	def gameStarted() {
	}

	def gameFinished() {
	}

	def boolean askRepeat(Throwable exc) {
		// TODO implement
		false
	}

	def idle() {
		Platform.runLater [
			// TODO: entertain me
			hallOfFame.show
		]
	}
	
	def showError(String message, Duration duration) {
		showMessage(message, 'error', duration)
	}
	
	def showInfo(String message, Duration duration) {
		showMessage(message, 'info', duration)
	}
	
	private def showMessage(String message, String stylePrefix, Duration duration) {
		Platform.runLater [
			val errorBox = new VBox => [
				setMaxSize(USE_PREF_SIZE, USE_PREF_SIZE)
				styleClass += #['outer-box', stylePrefix + '-box']
				children += new Label(message) => [
					styleClass += #[stylePrefix + '-label']
				]
			]
			messagePane.children += errorBox
			val fade = new FadeTransition => [
				node = errorBox
				fromValue = 1
				toValue = 0
				onFinished = [
					messagePane.children -= errorBox
				]
			]
			if(duration == INDEFINITE) {
				errorBox.children += new Button('OK') => [
					onAction = [
						fade.play
					]
				]
			} else {
				fade => [
					delay = duration
					play 
				]
			}
		]
	}
}
