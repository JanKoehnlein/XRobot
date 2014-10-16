package org.xtext.xrobot.game.display

import javafx.application.Platform
import javafx.scene.Parent
import javafx.scene.control.Label
import javafx.scene.control.OverrunStyle
import javafx.scene.layout.StackPane
import javafx.scene.shape.Ellipse
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.util.AudioService

import static java.lang.Math.*
import static org.xtext.xrobot.camera.ICamera.*

import static extension org.xtext.xrobot.api.GeometryExtensions.*

class Balloon extends Parent implements AudioService.Listener, IRobotListener {
	
	new(PlayerSlot slot) {
		AudioService.instance.addAudioListener(slot.robotID, this)
		slot.addRobotListener(this)
	}
	
	override audioStarted(String text) {
		Platform.runLater [
			val textLabel = new Label(text)
			children += new StackPane => [
				children += new Ellipse => [ e | 
					textLabel.boundsInLocalProperty.addListener [ p, o, n |
						e.radiusX = n.width / sqrt(2) + 1
						e.radiusY = n.height / sqrt(2) + 1
					]
					e.styleClass += 'balloon'
				]
				children += textLabel => [
					styleClass += 'balloon'
					textOverrun = OverrunStyle.ELLIPSIS
					wrapText = true
					setMaxSize(200, 100)
					setMinSize(50, 50)
				]
			]
		]
	}
	
	override audioStopped() {
		Platform.runLater [
			if(!children.empty) 
				children.remove(0)
		]
	}
	
	override stateRead(IRemoteRobot robot) {
		Platform.runLater [
			placeBubble(robot.ownPosition, robot.opponentPosition)
		]
	}
	
	private def placeBubble(RobotPosition own, RobotPosition opponent) {
	 	val bubblePosition = 2 * own.toVector - opponent.toVector
		layoutX = bubblePosition.x * RESOLUTION_X / WIDTH_IN_CM
		layoutY = bubblePosition.y * RESOLUTION_Y / HEIGHT_IN_CM
	}
	
	override modeChanged(IRemoteRobot robot, Mode newMode) {
	}
	
	override stateChanged(IRemoteRobot robot) {
	}
	
	override variableChanged(String name, Object value) {
	}
	
	override lineChanged(int line) {
	}
}