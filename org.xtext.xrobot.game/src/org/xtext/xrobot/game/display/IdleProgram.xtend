package org.xtext.xrobot.game.display

import com.google.inject.Inject
import javafx.animation.FadeTransition
import javafx.animation.Interpolator
import javafx.animation.ParallelTransition
import javafx.animation.RotateTransition
import javafx.animation.ScaleTransition
import javafx.animation.SequentialTransition
import javafx.geometry.Point3D
import javafx.scene.control.Label
import javafx.scene.control.OverrunStyle
import javafx.scene.effect.InnerShadow
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.Pane
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import javafx.scene.paint.Color

import static extension javafx.util.Duration.*

class IdleProgram extends StackPane {

	@Inject HallOfFameTable hallOfFameTable

	Pane joinUs = new VBox

	Label logo = new Label('XRobots')

	SequentialTransition animation

	def init() {
		if (children.empty) {
			children += hallOfFameTable
			children += joinUs => [
				setMaxSize(USE_PREF_SIZE, USE_PREF_SIZE)
				styleClass += #['hof-light', 'outer-box']
				children += new Label('Enter Your Own Program')
				children += new ImageView(new Image(IdleProgram.getResourceAsStream('/qrcode.jpg')))
				opacity = 0
			]
			children += logo => [
				setMaxSize(USE_PREF_SIZE, USE_PREF_SIZE)
				styleClass += 'logo'
				textOverrun = OverrunStyle.CLIP
				opacity = 0
				effect = new InnerShadow => [
					color = Color.RED
					width = 20
					height = 20
				]
			]
		}
	}

	def start() {
		joinUs.opacity = 0
		logo.scaleX = 0
		logo.scaleY = 0
		visible = true
		hallOfFameTable.update
		animation = createAnimation
		animation.play
	}

	def stop() {
		animation.stop
		hallOfFameTable.hide
		joinUs.opacity = 0
		logo.opacity = 0
		visible = false
	}

	private def createAnimation() {
		new SequentialTransition => [
			children += hallOfFameTable.animation
			children += new ParallelTransition => [
				children += new RotateTransition => [
					axis = new Point3D(1, 1, 1)
					fromAngle = 0
					toAngle = 720
					node = logo
					interpolator = Interpolator.EASE_OUT
					duration = 600.millis
				]
				children += new ScaleTransition => [
					fromX = 0
					toX = 0.8
					fromY = 0
					toY = 1
					node = logo
					interpolator = Interpolator.EASE_OUT
					duration = 1000.millis
				]
			]
			children += new FadeTransition => [
				fromValue = 1
				toValue = 0
				node = logo
				delay = 5.seconds
				duration = 100.millis
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
