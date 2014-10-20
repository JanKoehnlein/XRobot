package org.xtext.xrobot.game.display

import com.google.inject.Inject
import java.util.List
import javafx.animation.FadeTransition
import javafx.animation.KeyFrame
import javafx.animation.KeyValue
import javafx.animation.SequentialTransition
import javafx.animation.Timeline
import javafx.scene.control.Label
import javafx.scene.control.OverrunStyle
import javafx.scene.layout.GridPane
import javafx.scene.layout.VBox
import javafx.scene.shape.Rectangle
import org.xtext.xrobot.game.ranking.PlayerRanking
import org.xtext.xrobot.game.ranking.RankingProvider

import static extension javafx.util.Duration.*

class HallOfFameTable extends VBox {

	List<GridPane> pages = newArrayList
	
	@Inject RankingProvider hallOfFameProvider
	
	val spacerRectangle = new Rectangle(0, 0, 0, 0) => [
			visible = false
	]
	
	double spacerHeight 

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

	def getAnimation() {
		new SequentialTransition => [ t |
			t.children += new FadeTransition => [
				node = this
				fromValue = 0
				toValue = 1
				duration = 1.millis
			]
			t.children += new Timeline => [
				cycleCount = 1
				autoReverse = false
				keyFrames += new KeyFrame(
					500.millis,
					new KeyValue(spacerRectangle.heightProperty, spacerHeight)
				)
				onFinished = [
					this.children.clear
					if(!pages.empty)
						this.children += pages.get(0)
				]
			]
			pages.forEach [ page, pageNr |
				t.children += page.children.map [ child |
					new FadeTransition => [
						node = child
						fromValue = 0
						toValue = 1
						cycleCount = 1
						duration = 10.millis
					]
				]
				t.children += new FadeTransition => [
					node = page
					fromValue = 1
					toValue = 0
					cycleCount = 1
					delay = 8.seconds
					duration = 200.millis
					onFinished = [
						this.children.clear
						if(pageNr == 0) {
							spacerHeight = page.layoutBounds.height 
							spacerRectangle.width = page.layoutBounds.width
						}
						if(pageNr < pages.size - 1) 
							this.children += pages.get(pageNr + 1)
					]
				]
			]
			t.children += new FadeTransition => [
				node = this
				fromValue = 1
				toValue = 0
				duration = 100.millis 
				onFinished = [
					spacerRectangle.height = 0
					children.setAll(spacerRectangle)
				]
			]
		]
	}

	def update() {
		val hallOfFame = hallOfFameProvider.hallOfFame.iterator
		pages.clear
		var rank = 1
		do {
			val page = new GridPane
			pages.add(page)
			page.styleClass += 'hof-content'
			val heading = page.addCell('Hall Of Fame', 0, 0, #['hof', 'title-label'])
			GridPane.setConstraints(heading, 0, 0, 6, 1)
			val styles = #['hof', 'boxed-label']
			page.addCell('#', 0, 1, styles + #['hof-rank'])
			page.addCell('Name', 1, 1, styles + #['hof-name'])
			page.addCell('W', 2, 1, styles + #['hof-number'])
			page.addCell('D', 3, 1, styles + #['hof-number'])
			page.addCell('L', 4, 1, styles + #['hof-number'])
			page.addCell('Score', 5, 1, styles + #['hof-score'])
			for(var i=0; i<10 && hallOfFame.hasNext; i++) 
				page.addRow(i+2, rank++, hallOfFame.next)
		} while(hallOfFame.hasNext)
		children.setAll(spacerRectangle)
	}
	
	private def addCell(GridPane page, Object value, int column, int row, String... styles) {
		val cell = new VBox
		page.add(cell => [
			styleClass += styles
			children += new Label(value.toString) => [
				setMaxSize(300, 30)
				styleClass += styles
				textOverrun = OverrunStyle.ELLIPSIS
			]
		], column, row)
		cell 
	}
	
	private def addRow(GridPane page, int row, int rank, PlayerRanking entry) {
		val styles = newArrayList('hof-light', 'boxed-label')
		switch entry {
			case hallOfFameProvider.blue:
				styles.add('hof-blue')
			case hallOfFameProvider.red:
				styles.add('hof-red')
		}
		page.addCell(String.format('%3d', rank), 0, row, styles + #['hof-score'])
		page.addCell(entry.name, 1, row, styles + #['hof-name'])
		page.addCell(entry.wins, 2, row, styles + #['hof-number'])
		page.addCell(entry.draws, 3, row, styles + #['hof-number'])
		page.addCell(entry.defeats, 4, row, styles + #['hof-number'])
		page.addCell(String.format('%4d', entry.score as int), 5, row, styles + #['hof-score'])
	}
}
