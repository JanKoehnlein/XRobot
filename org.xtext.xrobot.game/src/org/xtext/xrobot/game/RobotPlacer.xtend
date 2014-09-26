package org.xtext.xrobot.game

import static java.lang.Math.*
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.api.Position
import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.api.IArena.*
import static org.xtext.xrobot.api.IRobotGeometry.*
import org.xtext.xrobot.net.INetConfig

class RobotPlacer {
	
	static val ANGLE_ACCURACY = 7.0
	
	def placeRobot(IRemoteRobot robot) {
		robot.rotateSpeed = robot.maxRotateSpeed
		robot.travelSpeed = robot.maxTravelSpeed

		val homePosition = switch robot.robotID {
			case Xtend: new Position(-ARENA_RADIUS * 0.6, 0)
			case Xtext: new Position(ARENA_RADIUS * 0.6, 0)
		}
		var direction = robot.ownPosition.getRelativeDirection(homePosition)
		while (direction.distance > POSITION_OFFSET + 1) {
			if (abs(direction.angle) <= ANGLE_ACCURACY) {
				println(robot.robotID + ": forward " + (direction.distance + POSITION_OFFSET))
				robot.forward(direction.distance + POSITION_OFFSET)
			} else if (abs(normalizeAngle(direction.angle - 180)) <= ANGLE_ACCURACY) {
				println(robot.robotID + ": backward " + (direction.distance - POSITION_OFFSET))
				robot.backward(direction.distance - POSITION_OFFSET)
			} else if (abs(direction.angle) <= 120) {
				println(robot.robotID + ": rotate " + direction.angle)
				robot.rotate(direction.angle)
			} else {
				println(robot.robotID + ": rotate " + normalizeAngle(direction.angle - 180))
				robot.rotate(normalizeAngle(direction.angle - 180))
			}
			robot.waitForUpdate(INetConfig.SOCKET_TIMEOUT)
			direction = robot.ownPosition.getRelativeDirection(homePosition)
		}

		val homeViewDirection = switch robot.robotID {
			case Xtend: 180
			case Xtext: 0
		}
		var angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		while (abs(angle) > ANGLE_ACCURACY) {
			println(robot.robotID + ": rotate " + angle)
			robot.rotate(angle)
			robot.waitForUpdate(INetConfig.SOCKET_TIMEOUT)
			angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		}
	}
	
}