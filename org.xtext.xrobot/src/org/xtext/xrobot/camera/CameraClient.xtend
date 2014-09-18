package org.xtext.xrobot.camera

import TUIO.TuioClient
import java.net.SocketTimeoutException
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.util.AveragingFilter
import org.xtext.xrobot.util.IValueStreamFilter

import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.camera.ICamera.*

class CameraClient {
	
	static val POSITION_BUFFER_SIZE = 12
	static val ANGLE_BUFFER_SIZE = 8

	val TuioClient client
	val RobotPosition[] robotPositions = newArrayOfSize(RobotID.values.length)
	var long[] timestamps = newLongArrayOfSize(RobotID.values.length)
	val IValueStreamFilter[] xposFilters = newArrayOfSize(RobotID.values.length)
	val IValueStreamFilter[] yposFilters = newArrayOfSize(RobotID.values.length)
	val IValueStreamFilter[] angleFilters = newArrayOfSize(RobotID.values.length)

	new(TuioClient client) throws SocketTimeoutException {
		this.client = client
		
		RobotID.values.forEach[ robotID |
			val index = robotID.ordinal
			xposFilters.set(index, new AveragingFilter(POSITION_BUFFER_SIZE))
			yposFilters.set(index, new AveragingFilter(POSITION_BUFFER_SIZE))
			angleFilters.set(index, new AveragingFilter(ANGLE_BUFFER_SIZE))
		]
	}
	
	def getRobotPosition(RobotID robotID) {
		var RobotPosition robotPosition
		val id = robotID.fiducialID
		val index = robotID.ordinal
		val oldTimestamp = timestamps.get(index)
		val tuioObject = client.getTuioObject(id)
		if (tuioObject != null && tuioObject.tuioTime.totalMilliseconds != oldTimestamp) {
			var x = (tuioObject.x - 0.5) * WIDTH_IN_CM
			var y = (0.5 - tuioObject.y) * HEIGHT_IN_CM
			// TUIO 0° means NORTH and 90° means EAST
			var angle = normalizeAngle(90 - tuioObject.angleDegrees)

			// Apply the filters			
			x = xposFilters.get(id).apply(x)
			y = yposFilters.get(id).apply(y)
			angle = angleFilters.get(id).apply(angle)
			
			robotPosition = new RobotPosition(x, y, robotID, angle)
			robotPositions.set(index, robotPosition)
			timestamps.set(index, tuioObject.tuioTime.totalMilliseconds)
		} else {
			robotPosition = robotPositions.get(index)
		}
		robotPosition
	}

	def getCameraSample(RobotID robotID) {
		val ownPosition = getRobotPosition(robotID)
		val opponentPosition = getRobotPosition(robotID.opponent)
		val result = new CameraSample(ownPosition, timestamps.get(robotID.ordinal),
				opponentPosition, timestamps.get(robotID.opponent.ordinal))
		result
	}
	
}
