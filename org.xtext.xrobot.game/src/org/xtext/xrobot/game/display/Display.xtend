package org.xtext.xrobot.game.display

import java.util.List
import javafx.animation.Interpolator
import javafx.animation.ScaleTransition
import javafx.animation.SequentialTransition
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.Scene
import javafx.scene.control.Label
import javafx.scene.layout.BorderPane
import javafx.scene.layout.StackPane
import javafx.stage.Screen
import javafx.stage.Stage
import javafx.stage.StageStyle
import javax.inject.Inject
import org.xtext.xrobot.game.PlayerSlot

import static extension javafx.scene.layout.BorderPane.*
import static extension javafx.util.Duration.*

class Display {

	@Inject BorderPane topLayer
	@Inject HallOfFameTable hallOfFame
	@Inject StackPane centerPane

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
						alignment = Pos.CENTER
					]
					val xtendBox = new PlayerSlotBox(slots.head)
					val xtextBox = new PlayerSlotBox(slots.last)
					slotBoxes = #[xtendBox, xtextBox]
					left = xtendBox
					xtendBox.alignment = Pos.CENTER_RIGHT
					xtendBox.margin = new Insets(20)
					right = xtextBox
					xtextBox.alignment = Pos.CENTER_LEFT
					xtextBox.margin = new Insets(20)
				], screenBounds.width, screenBounds.height) => [
				fill = null
				stylesheets += 'org/xtext/xrobot/game/display/Styles.css'
			]
			show
		]
		idle
		prepareGame
	}

	def prepareGame() {
		hallOfFame.hide
		countdown()
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
		Thread.sleep(3000)
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
		false
	}

	def idle() {
		// TODO: entertain me
		hallOfFame.show
	}
}
