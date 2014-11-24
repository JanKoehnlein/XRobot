package org.xtext.xrobot.game.display

import javafx.application.Platform
import javafx.scene.Parent
import javafx.scene.control.Label
import javafx.scene.control.OverrunStyle
import javafx.scene.layout.StackPane
import javafx.scene.shape.Ellipse
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.camera.CameraConstants
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.util.AudioService

import static java.lang.Math.*

class Balloon extends Parent implements AudioService.Listener, IRobotListener {
	
	static val BUBBLE_DISTANCE = 30.0
	
	static val POS_TO_SCREEN = CameraConstants.RESOLUTION_X as double / CameraConstants.WIDTH_IN_CM
	
	static val POSITION_UPDATE_TIME = 200L
	
	var long lastPositionUpdate
	
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
					setMaxSize(250, 100)
					setMinSize(50, 50)
				]
			]
		]
	}
	
	override audioStopped() {
		Platform.runLater [
			children.clear
		]
	}
	
	override stateRead(IRemoteRobot robot) {
		if (!children.empty && System.currentTimeMillis - lastPositionUpdate >= POSITION_UPDATE_TIME) {
			lastPositionUpdate = System.currentTimeMillis
			Platform.runLater [
				placeBubble(robot.ownPosition, robot.opponentPosition)
			]
		}
	}
	
	private def placeBubble(RobotPosition own, RobotPosition opponent) {
		val bounds = layoutBounds
		val bubbleOffset = Math.max(bounds.width / 2, bounds.height / 2) + BUBBLE_DISTANCE
		val delta = own.toVector - opponent.toVector
		val bubblePosition = own.toVector * POS_TO_SCREEN + Vector.polar(bubbleOffset, delta.angle)
		relocate(bubblePosition.x - bounds.width / 2, bubblePosition.y - bounds.height / 2)
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