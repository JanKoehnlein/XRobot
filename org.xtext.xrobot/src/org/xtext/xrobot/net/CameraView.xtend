package org.xtext.xrobot.net

import TUIO.TuioClient
import org.xtext.xrobot.api.RobotSight
import org.xtext.xrobot.api.IRobot

class CameraView {
	
	private static val MAX_ANGLE = 40.0
	
	private val TuioClient client
	
	private val robotNames = #["Xtext", "Xtend"]
	
	private def getObjectId(String robotName) {
		var i = 0
		while (i < robotNames.size) {
			if (robotNames.get(i) == robotName) {
				return i
			}
			i++
		}
	}
	
	private def getOpponentId(int objectId) {
		1 - objectId
	}
	
	new(TuioClient client) {
		this.client = client
	}
	
	def RobotSight getRobotSight(IRobot robot) {
		val id = robot.name.objectId
		val selfObject = getObject(id)
		val opponentObject = getObject(getOpponentId(id))
		if (selfObject == null || opponentObject == null)
			return new RobotSight(0, 0, false)
		
		// transform fiducial orientation
		val orientation = 1.5 * Math.PI - selfObject.angle
		val diffx = opponentObject.x - selfObject.x
		// invert the y axis to have the origin bottom left
		val diffy = selfObject.y - opponentObject.y
		val angle = Math.atan2(diffy, diffx)
		var relativeAngle = angle - orientation
		if (relativeAngle > Math.PI)
			relativeAngle -= 2 * Math.PI
		else if (relativeAngle < -Math.PI)
			relativeAngle += 2 * Math.PI
		
		if (Math.abs(relativeAngle) > Math.toRadians(MAX_ANGLE)) {
			return new RobotSight(0, 0, false)
		} else {
			val distance = Math.sqrt(diffx * diffx + diffy * diffy)
			return new RobotSight(relativeAngle, distance, true)
		}
	}
	
	def getObject(int id) {
		client.tuioObjects.findFirst[it.symbolID == id]
	}
	
}
