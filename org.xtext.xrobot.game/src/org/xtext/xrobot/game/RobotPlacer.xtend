package org.xtext.xrobot.game

import static java.lang.Math.*
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.api.Position
import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.api.IArena.*
import org.xtext.xrobot.net.INetConfig

class RobotPlacer {
	
	static val DISTANCE_ACCURACY = 5.0
	static val ANGLE_ACCURACY = 8.0
	
	def placeRobot(IRemoteRobot robot) {
		robot.rotateSpeed = robot.maxRotateSpeed * 0.7
		robot.travelSpeed = robot.maxTravelSpeed

		val homePosition = switch robot.robotID {
			case Xtend: new Position(-ARENA_RADIUS * 0.6, 0)
			case Xtext: new Position(ARENA_RADIUS * 0.6, 0)
		}
		var direction = robot.ownPosition.getRelativeDirection(homePosition)
		while (direction.distance > DISTANCE_ACCURACY) {
			if (abs(direction.angle) <= ANGLE_ACCURACY) {
				robot.forward(direction.distance)
			} else if (abs(normalizeAngle(direction.angle - 180)) <= ANGLE_ACCURACY) {
				robot.backward(direction.distance)
			} else if (abs(direction.angle) <= 120) {
				robot.rotate(direction.angle)
			} else {
				robot.rotate(normalizeAngle(direction.angle - 180))
			}
			robot.waitForUpdate
			direction = robot.ownPosition.getRelativeDirection(homePosition)
		}

		val homeViewDirection = switch robot.robotID {
			case Xtend: 180
			case Xtext: 0
		}
		var angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		while (abs(angle) > ANGLE_ACCURACY) {
			robot.rotate(angle)
			robot.waitForUpdate
			angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		}
	}
	
	private def waitForUpdate(IRemoteRobot robot) {
		Thread.sleep(200)
		robot.waitForUpdate(INetConfig.SOCKET_TIMEOUT)
	}
	
}