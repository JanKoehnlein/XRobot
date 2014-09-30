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

class PlayerSlotBox extends VBox implements PlayerSlot.Listener {
	
	static val MAX_MODES = 10 
	
	Pane programBox
	Label programLabel
	Pane modesBox
	
	PlayerSlot slot
	
	new(PlayerSlot slot) {
		this.slot = slot
		slot.addChangeListener(this)
		val style = slot.robotID.name.toLowerCase
		val lightStyle = style + '-light'
		styleClass += #[style, 'outer-box']
		alignment = Pos.TOP_CENTER
		children += programBox = new StackPane => [
			children += programLabel= new Label()
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
			if(slot.program == null) {
				programBox => [
					styleClass.setAll('inner-box', 'robot-inner-box', 'available')
				]
				programLabel => [
					styleClass.setAll('inner-box', 'robot-inner-box', 'available')
					text = '''
						AVAILABLE
						Token «slot.token.value»
					'''
				]
				modesBox.children.clear
			} else {
				programBox => [
					styleClass.setAll('inner-box', 'robot-inner-box', 'locked')
				]
				programLabel => [
					styleClass.setAll('inner-box', 'robot-inner-box', 'locked')
					text = '''
						LOCKED
						«slot.program.name»
						(«slot.program.author»)
					'''
				]
			}
		]
	}
	
	override stateRead(IRemoteRobot robot) {
	}
	
	override modeChanged(IRemoteRobot robot, Mode newMode) {
		Platform.runLater [
			val modeLabels = modesBox.children
			val newLabel = new Label => [
			 	text = newMode.name
			 	styleClass.setAll('boxed-label')
		 	]
			if(modeLabels.empty) {
				modeLabels.add(newLabel)
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
	
	override stateChanged(IRemoteRobot robot) {
	}
	
	override variableChanged(String name, Object value) {
	}
	
	override lineChanged(int line) {
	}
}