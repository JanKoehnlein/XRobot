package org.xtext.xrobot.game.display

import com.google.inject.Inject
import javafx.animation.FadeTransition
import javafx.animation.KeyFrame
import javafx.animation.KeyValue
import javafx.animation.SequentialTransition
import javafx.animation.Timeline
import javafx.scene.control.Label
import javafx.scene.layout.GridPane
import javafx.scene.layout.VBox
import javafx.scene.shape.Rectangle
import org.xtext.xrobot.game.ranking.PlayerRanking
import org.xtext.xrobot.game.ranking.RankingProvider

import static extension javafx.util.Duration.*

class HallOfFameTable extends VBox {

	@Inject GridPane content
	
	@Inject RankingProvider hallOfFameProvider
	
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
		new SequentialTransition => [ 
			children += new Timeline => [
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
		addCell('#', 0, 1, styles + #['hof-rank'])
		addCell('Name', 1, 1, styles + #['hof-name'])
		addCell('W', 2, 1, styles + #['hof-number'])
		addCell('D', 3, 1, styles + #['hof-number'])
		addCell('L', 4, 1, styles + #['hof-number'])
		addCell('Score', 5, 1, styles + #['hof-score'])
		hallOfFame.forEach [ entry, i |
			addRow(i+2, i+1, entry)
		]
		children.setAll(spacerRectangle)
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
	
	private def addRow(int row, int rank, PlayerRanking entry) {
		val styles = #['hof-light', 'boxed-label']
		addCell(String.format('%3d', rank), 0, row, styles + #['hof-score'])
		addCell(entry.name, 1, row, styles + #['hof-name'])
		addCell(entry.wins, 2, row, styles + #['hof-number'])
		addCell(entry.draws, 3, row, styles + #['hof-number'])
		addCell(entry.defeats, 4, row, styles + #['hof-number'])
		addCell(String.format('%4d', entry.score as int), 5, row, styles + #['hof-score'])
	}
}
