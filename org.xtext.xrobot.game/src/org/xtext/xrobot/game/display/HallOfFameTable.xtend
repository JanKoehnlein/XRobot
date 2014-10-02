package org.xtext.xrobot.game.display

import com.google.inject.Inject
import javafx.animation.FadeTransition
import javafx.animation.KeyFrame
import javafx.animation.KeyValue
import javafx.animation.SequentialTransition
import javafx.animation.Timeline
import javafx.geometry.HPos
import javafx.scene.control.Label
import javafx.scene.layout.GridPane
import javafx.scene.layout.VBox
import javafx.scene.shape.Rectangle
import org.xtext.xrobot.game.HallOfFameEntry
import org.xtext.xrobot.game.HallOfFameProvider

import static extension javafx.util.Duration.*

class HallOfFameTable extends VBox {

	@Inject GridPane content
	
	@Inject HallOfFameProvider hallOfFameProvider
	
	val spacerRectangle = new Rectangle(0, 0, 323, 0) => [
			visible = false
	]
	
	new() {
		styleClass += #['hof', 'outer-box']
		setMaxSize(USE_PREF_SIZE, USE_PREF_SIZE)
	}

	def hide() {
		new FadeTransition => [
			node = this
			fromValue = 1
			toValue = 0
			duration = 100.millis
			onFinished = [
				spacerRectangle.height = 0
				children.setAll(spacerRectangle)
			]
		]
	}

	def show() {
		update => [
			onFinished = [
				new SequentialTransition => [
					children += content.children.map [ child |
						new FadeTransition => [
							node = child
							fromValue = 0
							toValue = 1
							cycleCount = 1
							duration = 10.millis
						]
					]
					play
				]
			]
		]
	}

	def update() {
		val hallOfFame = hallOfFameProvider.hallOfFame
		content.children.clear 
		content.styleClass += 'hof-content'
		val heading = addCell('Hall Of Fame', 0, 0, #['hof', 'title-label'])
		GridPane.setConstraints(heading, 0, 0, 6, 1)
		val styles = #['hof', 'boxed-label']
		#['#', 'Name', 'W', 'D', 'L', 'S'].forEach [ string, i |
			if(i<10) {
				addCell(string, i, 1, styles) => [
					GridPane.setHalignment(it, HPos.CENTER)
				]
			}
		]
		hallOfFame.forEach [ entry, i |
			addRow(i+2, i+1, entry)
		]
		children.setAll(spacerRectangle)
		
		new SequentialTransition => [ t |
			t.children += new Timeline => [
				cycleCount = 1
				autoReverse = false
				keyFrames += new KeyFrame(
					500.millis,
					new KeyValue(spacerRectangle.heightProperty, 560)
				)
				onFinished = [
					this.children.clear
					this.children += content
				]
			]
		]
	}
	
	private def addCell(Object value, int column, int row, String... styles) {
		val cell = new VBox
		content.add(cell => [
			styleClass += styles
			children += new Label(value.toString) => [
				styleClass += styles
			]
		], column, row)
		cell 
	}
	
	private def addRow(int row, int rank, HallOfFameEntry entry) {
		val styles = #['hof-light', 'boxed-label']
		addCell(String.format('%3d', rank), 0, row, styles)
		addCell(entry.name, 1, row, styles)
		addCell(entry.wins, 2, row, styles)
		addCell(entry.draws, 3, row, styles)
		addCell(entry.defeats, 4, row, styles)
		addCell(String.format('%2.1f', entry.score), 5, row, styles)
	}
}
