package org.xtext.xrobot.game.display

import javafx.animation.SequentialTransition
import com.google.inject.Inject
import javafx.animation.FadeTransition
import static extension javafx.util.Duration.*
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import javafx.scene.layout.Pane
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.control.Label

class IdleProgram extends StackPane {
	
	@Inject HallOfFameTable hallOfFameTable

	Pane joinUs = new VBox
	
	SequentialTransition animation

	def init() {
		if(children.empty) {
			children += hallOfFameTable
			children += joinUs => [
				setMaxSize(USE_PREF_SIZE, USE_PREF_SIZE)
				styleClass += #['hof-light', 'outer-box']
				children += new Label('Enter Your Own Program')
				children += new ImageView(new Image(IdleProgram.getResourceAsStream('/qrcode.jpg')))
				opacity = 0
			]
		}
		animation = createAnimation
	}
	
	def start() {
		visible = true
		animation.playFromStart
	}
	
	def stop() {
		animation.pause
		hallOfFameTable.hide
		joinUs.opacity = 0
		visible = false
	}
	
	private def createAnimation() {
		new SequentialTransition => [
			children += hallOfFameTable.show
			children += hallOfFameTable.hide => [
				delay = 5.seconds
			]
			children += new FadeTransition => [
				fromValue = 0
				toValue = 1
				node = joinUs
				duration = 300.millis
			]
			children += new FadeTransition => [
				fromValue = 1
				toValue = 0
				node = joinUs
				delay = 5.seconds
				duration = 100.millis
			]
			cycleCount = -1 
		]
	}
	
}