package org.xtext.xrobot.camera

import com.illposed.osc.OSCListener
import com.illposed.osc.OSCMessage
import com.illposed.osc.OSCPortIn
import java.util.Arrays
import java.util.Collections
import java.util.Date
import java.util.List
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.util.AveragingFilter
import org.xtext.xrobot.util.IValueStreamFilter

import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.camera.ICamera.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class CameraClient {
	
	static val POSITION_BUFFER_SIZE = 12
	static val ANGLE_BUFFER_SIZE = 8
	static val TUIO_PORT = 3333
	
	static val ROBOT_NUM = RobotID.values.length
	val RobotPosition[] robotPositions = newArrayOfSize(ROBOT_NUM)
	val long[] timestamps = newLongArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] xposFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] yposFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] angleFilters = newArrayOfSize(ROBOT_NUM)
	
	var OSCPortIn oscPort

	new() {
		RobotID.values.forEach[ robotID |
			val index = robotID.ordinal
			xposFilters.set(index, new AveragingFilter(POSITION_BUFFER_SIZE))
			yposFilters.set(index, new AveragingFilter(POSITION_BUFFER_SIZE))
			angleFilters.set(index, new AveragingFilter(ANGLE_BUFFER_SIZE))
		]
	}
	
	def connect() {
		oscPort = new OSCPortIn(TUIO_PORT);
		oscPort.addListener("/tuio/2Dobj", new TuioListener(this));
		oscPort.startListening();
	}
	
	def disconnect() {
		if (oscPort != null) {
			oscPort.stopListening();
			ignoreExceptions[Thread.sleep(100)]
			oscPort.close();
		}
	}
	
	private def setRobotPosition(RobotID robotID, long timestamp,
			float rawXpos, float rawYpos, float rawAngle) {
		var x = (rawXpos - 0.5) * WIDTH_IN_CM
		var y = (0.5 - rawYpos) * HEIGHT_IN_CM
		// TUIO 0° means NORTH and 90° means EAST
		var angle = normalizeAngle(90 - Math.toDegrees(rawAngle))

		// Apply the filters			
		val index = robotID.ordinal
		x = xposFilters.get(index).apply(x)
		y = yposFilters.get(index).apply(y)
		angle = angleFilters.get(index).apply(angle)
		
		val robotPosition = new RobotPosition(x, y, robotID, angle)
		robotPositions.set(index, robotPosition)
		timestamps.set(index, timestamp)
	}
	
	def getCameraSample(RobotID robotID) {
		val ownPosition = robotPositions.get(robotID.ordinal)
		val ownTimestamp = timestamps.get(robotID.ordinal)
		val opponentPosition = robotPositions.get(robotID.opponent.ordinal)
		val opponentTimestamp = timestamps.get(robotID.opponent.ordinal)
		new CameraSample(ownPosition, ownTimestamp, opponentPosition, opponentTimestamp)
	}
	
	private static class TuioListener implements OSCListener {
		
		val CameraClient client
		val List<Object>[] setCommands = newArrayOfSize(ROBOT_NUM)
		val boolean[] aliveCommands = newBooleanArrayOfSize(ROBOT_NUM)
		
		var lastFrame = 0
		
		new(CameraClient client) {
			this.client = client
			RobotID.values.forEach[ robotID |
				setCommands.set(robotID.ordinal, Collections.emptyList)
			]
		}
		
		override acceptMessage(Date time, OSCMessage message) {
			if (message.getAddress().equals("/tuio/2Dobj")) {
				// First 'alive' message, then 'set' message, then 'fseq' message
				val args = message.arguments
				if (args.isEmpty) {
					return
				}
				val command = args.get(0) as String
				
				if (command.equals("alive")) {
					Arrays.fill(aliveCommands, false)
					val argIter = args.listIterator(1)
					while (argIter.hasNext) {
						val int fid_id = argIter.next as Integer
						val robotID = RobotID.forFiducialID(fid_id)
						if (robotID != null) {
							aliveCommands.set(robotID.ordinal, true)
						}
					}
	
				} else if (command.equals("set") && args.size > 2) {
					val int fid_id  = args.get(2) as Integer
					val robotID = RobotID.forFiducialID(fid_id)
					if (robotID != null) {
						setCommands.set(robotID.ordinal, args)
					}
					
				} else if (command.equals("fseq") && args.size > 1) {
					val int fseq = args.get(1) as Integer
					if (fseq > lastFrame || lastFrame - fseq > Integer.MAX_VALUE / 2) {
						lastFrame = fseq
						val timestamp = System.currentTimeMillis
						RobotID.values.forEach[ robotID |
							val index = robotID.ordinal
							val setComArgs = setCommands.get(index)
							if (aliveCommands.get(index) && setComArgs.size > 5) {
								val float xpos = setComArgs.get(3) as Float
								val float ypos = setComArgs.get(4) as Float
								val float angle = setComArgs.get(5) as Float
								client.setRobotPosition(robotID, timestamp, xpos, ypos, angle)
							}
						]
					}
				}
			}
		}
		
	}
	
}
