package org.xtext.xrobot.game.display

import javafx.scene.Parent
import javafx.scene.control.Label
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.server.IRemoteRobot
import javafx.application.Platform

class PlayerSlotBox extends Parent implements PlayerSlot.Listener {
	
	Label programLabel
	Label modesLabel
	
	PlayerSlot slot
	
	new(PlayerSlot slot) {
		this.slot = slot
		slot.addChangeListener(this)
		val style = slot.robotID.name.toLowerCase
		val lightStyle = style + '-light'
		children += new VBox => [
			styleClass += #[style, 'outer-box']
			children += programLabel= new Label() => [
				styleClass += #['inner-box']
			]
			children += new StackPane => [
				styleClass += #[lightStyle, 'inner-box']
				children += modesLabel = new Label() => [
					styleClass += #['inner-box']
				]
			]
		]
		slotChanged
		val robot = slot.robotFactory.newRobot(CancelIndicator.NullImpl)
		stateRead(robot)
		stateChanged(robot)
		slot.robotFactory.release
	}
	
	def getRobotID() {
		slot.robotID
	}
	
	override slotChanged() {
		Platform.runLater [
			if(slot.program == null) {
				programLabel => [
					styleClass += #[style, 'robot-inner-box', 'available']
					text = '''
						AVAILABLE
						Token «slot.token.value»
					'''
				]
			} else {
				programLabel => [
					styleClass += #[style, 'robot-inner-box', 'locked']
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
			modesLabel.text = newMode.name + '\n' + modesLabel.text
		]
	}
	
	override stateChanged(IRemoteRobot robot) {
	}
	
	override variableChanged(String name, Object value) {
	}
	
	override lineChanged(int line) {
	}
}