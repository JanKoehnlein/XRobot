package org.xtext.xrobot.camera

import TUIO.TuioClient
import java.net.SocketTimeoutException
import java.util.List
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.util.AveragingFilter
import org.xtext.xrobot.util.IValueStreamFilter

import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.camera.ICamera.*

class CameraClient {
	
	static val POSITION_BUFFER_SIZE = 12
	static val ANGLE_BUFFER_SIZE = 12

	val TuioClient client
	val List<IValueStreamFilter> xposFilters = newArrayList()
	val List<IValueStreamFilter> yposFilters = newArrayList()
	val List<IValueStreamFilter> angleFilters = newArrayList()

	new(TuioClient client) throws SocketTimeoutException {
		this.client = client
		var startTime = System.currentTimeMillis
		while(client.tuioObjects.size() != 2) {
			if(System.currentTimeMillis - startTime > 5* INetConfig.SOCKET_TIMEOUT)
				throw new SocketTimeoutException('Missing updates from camera server. Got ' + client.tuioObjects.size + ' but needed 2.')
			Thread.sleep(50)
		}
		
		RobotID.values.forEach[ robotID |
			xposFilters.add(new AveragingFilter(POSITION_BUFFER_SIZE))
			yposFilters.add(new AveragingFilter(POSITION_BUFFER_SIZE))
			angleFilters.add(new AveragingFilter(ANGLE_BUFFER_SIZE))
		]
	}

	def getRobotPositions() {
		val tuioObjects = client.tuioObjects
		val List<RobotPosition> result = newArrayList
		RobotID.values.forEach [ robotID |
			val id = robotID.ordinal
			val tuioObject = tuioObjects.findFirst[symbolID == id]
			if (tuioObject != null) {
				val x = xposFilters.get(id).apply((tuioObject.x - 0.5) * WIDTH_IN_CM)
				val y = yposFilters.get(id).apply((0.5 - tuioObject.y) * HEIGHT_IN_CM)
				// TUIO 0° means NORTH and 90° means EAST
				val angle = angleFilters.get(id).apply(
					normalizeAngle(90 - tuioObject.angleDegrees))
				result.add(new RobotPosition(x, y, robotID, angle))
			}
		]
		result
	}
}
