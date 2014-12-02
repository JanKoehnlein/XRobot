package org.xtext.xrobot.game.display

import javafx.application.Platform
import javafx.geometry.Rectangle2D
import javafx.scene.Parent
import javafx.scene.control.Label
import javafx.scene.control.OverrunStyle
import javafx.scene.layout.StackPane
import javafx.scene.shape.Ellipse
import org.eclipse.xtend.lib.annotations.Accessors
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
	
	static val BUBBLE_DISTANCE = 40.0
	
	static val POSITION_UPDATE_TIME = 200L
	
	val Vector posToScreenFactor
	
	long lastPositionUpdate
	
	RobotPosition lastOwnPosition
	
	RobotPosition lastOpponentPosition
	
	@Accessors(PUBLIC_SETTER)
	var boolean invertYAxis = true
	
	new(PlayerSlot slot, Rectangle2D screenBounds) {
		AudioService.instance.addAudioListener(slot.robotID, this)
		slot.addRobotListener(this)
		// Screen format: 0.5625 = 9/16
		posToScreenFactor = Vector.cartesian(0.5625 * screenBounds.width / CameraConstants.WIDTH_IN_CM,
				screenBounds.height / CameraConstants.WIDTH_IN_CM)
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
			if (lastOwnPosition != null && lastOpponentPosition != null) {
				placeBubble(lastOwnPosition, lastOpponentPosition)
			}
		]
	}
	
	override audioStopped() {
		Platform.runLater [
			children.clear
		]
	}
	
	override stateRead(IRemoteRobot robot) {
		if (!children.empty && System.currentTimeMillis - lastPositionUpdate >= POSITION_UPDATE_TIME) {
			lastOwnPosition = null
			lastOpponentPosition = null
			lastPositionUpdate = System.currentTimeMillis
			Platform.runLater [
				placeBubble(robot.ownPosition, robot.opponentPosition)
			]
		} else {
			lastOwnPosition = robot.ownPosition
			lastOpponentPosition = robot.opponentPosition
		}
	}
	
	private def placeBubble(RobotPosition own, RobotPosition opponent) {
		val delta = own.toVector - opponent.toVector
		val bounds = layoutBounds
		val bubbleOffset = calcEllipseOffset(bounds.width, bounds.height, delta.angle) + BUBBLE_DISTANCE
		val ownScreenPos = Vector.cartesian(posToScreenFactor.x * own.x, posToScreenFactor.y * own.y)
		val bubblePosition = ownScreenPos + Vector.polar(bubbleOffset, delta.angle)
		if (invertYAxis)
			relocate(bubblePosition.x - bounds.width / 2, -bubblePosition.y - bounds.height / 2)
		else
			relocate(bubblePosition.x - bounds.width / 2, bubblePosition.y - bounds.height / 2)
	}
	
	private def calcEllipseOffset(double w, double h, double a) {
		val h2 = h * h
		val w2 = w * w
		if (w >= h) {
			val cosa = cos(toRadians(a))
			val cosa2 = cosa * cosa
			val eccentricity2 = 1 - h2 / w2
			return h / sqrt(1 - eccentricity2 * cosa2)
		} else {
			val cosa = cos(toRadians(a + 90))
			val cosa2 = cosa * cosa
			val eccentricity2 = 1 - w2 / h2
			return w / sqrt(1 - eccentricity2 * cosa2)
		}
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