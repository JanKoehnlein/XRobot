package org.xtext.xrobot.game.display

import javafx.animation.KeyFrame
import javafx.animation.KeyValue
import javafx.animation.Timeline
import javafx.application.Platform
import javafx.geometry.Pos
import javafx.scene.control.Label
import javafx.scene.layout.Pane
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import javafx.scene.shape.Rectangle
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.server.IRemoteRobot

import static extension javafx.util.Duration.*
import static org.xtext.xrobot.game.PlayerStatus.*
import javafx.scene.effect.Bloom
import javafx.animation.FadeTransition

class PlayerSlotBox extends VBox implements PlayerSlot.Listener {
	
	static val MAX_MODES = 10 
	
	Pane statusBox
	Label statusLabel
	Pane programBox
	Label programLabel
	Label authorLabel
	Pane modesBox
	
	PlayerSlot slot
	
	new(PlayerSlot slot) {
		this.slot = slot
		slot.addChangeListener(this)
		val style = slot.robotID.name.toLowerCase
		val lightStyle = style + '-light'
		styleClass += #[style, 'outer-box']
		alignment = Pos.TOP_CENTER
		children += statusBox = new StackPane => [
			children += statusLabel= new Label() => [
				styleClass.setAll('boxed-label')
			]
			styleClass += #[lightStyle, 'inner-box']
		]
		children += programBox = new VBox => [
			children += programLabel= new Label => [
				styleClass.setAll('inner-box', 'robot-inner-box', 'title-label')
			]
			children += authorLabel= new Label => [
				styleClass.setAll('inner-box', 'robot-inner-box')
			]
			styleClass += #[lightStyle, 'inner-box']
		]
		children += modesBox = new VBox => [
			styleClass += #[lightStyle, 'inner-box']
		]
		slotChanged
		val robot = slot.robotFactory.newRobot(CancelIndicator.NullImpl)
		stateRead(robot)
		stateChanged(robot)
		slot.robotFactory.release
	}
	
	override isResizable() {
		false
	}
	
	def getRobotID() {
		slot.robotID
	}
	
	override slotChanged() {
		Platform.runLater [
			statusBox => [
				styleClass.setAll('inner-box', slot.robotID.name.toLowerCase + '-' + slot.status.style)
			]
			statusLabel.text = slot.status.label
			effect = if(slot.status == WINNER) 
						new Bloom(0.9)
			 		else 
			 			null
			val program = slot.program
			if(program == null) {
				programLabel.text = 'Use Token'
				authorLabel => [
					styleClass.setAll('inner-box', 'robot-inner-box', 'token')
					text = slot.token.value
				]
				modesBox.children.clear
			} else {
				programLabel.text = program.name
				authorLabel => [
					styleClass.setAll('inner-box', 'robot-inner-box')
					text = program.author
				]
			}
		]
	}
	
	override stateRead(IRemoteRobot robot) {
	}
	
	override modeChanged(IRemoteRobot robot, Mode newMode) {
		Platform.runLater [
			val modeLabels = modesBox.children
			if((modeLabels.head as Label)?.text == newMode.name) {
				new FadeTransition => [
					node = modeLabels.head
					fromValue = 0
					toValue = 1
					duration = 300.millis
					play
				]
				return
			} 
			val newLabel = new Label => [
			 	text = newMode.name
			 	styleClass.setAll('boxed-label')
		 	]
		 	modeLabels.forEach [ it, i |
		 		opacity = (1 - (1.0 + i) / MAX_MODES).squared
		 	]
			if(modeLabels.empty) {
				modeLabels.add(newLabel)
				return
			}
			val height = modeLabels.head.boundsInLocal.height
		 	val rect = new Rectangle(0,0,0,0)
			modeLabels.add(0, rect)
			new Timeline => [
				cycleCount = 1
				autoReverse = false
				keyFrames += new KeyFrame(
					50.millis,
					new KeyValue(rect.heightProperty, height)
				)
				onFinished = [
					if (modeLabels.size > MAX_MODES) 
					 	modeLabels -= modeLabels.last
					modeLabels.set(0, newLabel)
			 	]
			 	play
		 	]
		]
	}
	
	private def squared(double x) {
		x*x
	}
	
	override stateChanged(IRemoteRobot robot) {
	}
	
	override variableChanged(String name, Object value) {
	}
	
	override lineChanged(int line) {
	}
}