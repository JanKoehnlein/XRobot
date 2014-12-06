/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.camera

import com.illposed.osc.OSCListener
import com.illposed.osc.OSCMessage
import com.illposed.osc.OSCPortIn
import java.util.Arrays
import java.util.Collections
import java.util.Date
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.util.AveragingFilter
import org.xtext.xrobot.util.IValueStreamFilter

import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.api.IRobot.*
import static org.xtext.xrobot.camera.CameraClient.*
import static org.xtext.xrobot.camera.CameraConstants.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

import static extension java.lang.Math.*

/**
 * A UDP client listening for TUIO messages with tracking data from a camera.
 * See {@link http://www.tuio.org}.
 */
class CameraClient {
	
	static val POSITION_BUFFER_SIZE = 10
	static val SPEED_BUFFER_SIZE = 12
	static val ANGLE_BUFFER_SIZE = 6
	static val TUIO_PORT = 3333
	
	static val ROBOT_NUM = RobotID.values.length
	val RobotPosition[] robotPositions = newArrayOfSize(ROBOT_NUM)
	val long[] timestamps = newLongArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] xposFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] yposFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] angleFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] xspeedFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] yspeedFilters = newArrayOfSize(ROBOT_NUM)
	val IValueStreamFilter[] rotSpeedFilters = newArrayOfSize(ROBOT_NUM)
	
	var OSCPortIn oscPort
	
	@Accessors(PUBLIC_SETTER)
	var boolean invertYAxis = true

	new() {
		RobotID.values.forEach[ robotID |
			val index = robotID.ordinal
			xposFilters.set(index, new AveragingFilter(POSITION_BUFFER_SIZE))
			yposFilters.set(index, new AveragingFilter(POSITION_BUFFER_SIZE))
			angleFilters.set(index, new AveragingFilter(ANGLE_BUFFER_SIZE, 360))
			xspeedFilters.set(index, new AveragingFilter(SPEED_BUFFER_SIZE))
			yspeedFilters.set(index, new AveragingFilter(SPEED_BUFFER_SIZE))
			rotSpeedFilters.set(index, new AveragingFilter(SPEED_BUFFER_SIZE))
		]
	}
	
	/**
	 * Start listening to the TUIO port.
	 */
	def connect() {
		oscPort = new OSCPortIn(TUIO_PORT);
		oscPort.addListener("/tuio/2Dobj", new TuioListener(this));
		oscPort.startListening();
	}
	
	/**
	 * Stop listening to the TUIO port.
	 */
	def disconnect() {
		if (oscPort != null) {
			oscPort.stopListening();
			ignoreExceptions[Thread.sleep(100)]
			oscPort.close();
		}
	}
	
	/**
	 * Store tracking information of a robot so it can be accessed with
	 * {@link #getCameraSample(RobotID)}. The information is processed with filtering and
	 * perspective correction.
	 */
	private def setRobotPosition(RobotID robotID, long timestamp,
			float rawXpos, float rawYpos, float rawAngle, float rawXspeed, float rawYspeed,
			float rawRotSpeed) {
		var Vector rawPos
		var Vector rawSpeed
		var double angle
		var double rotSpeed
		if (invertYAxis) {
			rawPos = Vector.cartesian((rawXpos - 0.5) * WIDTH_IN_CM,
					(0.5 - rawYpos) * HEIGHT_IN_CM)
			rawSpeed = Vector.cartesian(rawXspeed * WIDTH_IN_CM, -rawYspeed * HEIGHT_IN_CM)
			angle = 90 - rawAngle.toDegrees
			rotSpeed = -rawRotSpeed.toDegrees
		} else {
			rawPos = Vector.cartesian((rawXpos - 0.5) * WIDTH_IN_CM,
					(rawYpos - 0.5) * HEIGHT_IN_CM)
			rawSpeed = Vector.cartesian(rawXspeed * WIDTH_IN_CM, rawYspeed * HEIGHT_IN_CM)
			angle = rawAngle.toDegrees - 90
			rotSpeed = rawRotSpeed.toDegrees
		}
		
		// Apply perspective correction
		val correctedPos = correctPositionPerspective(rawPos)
		val correctedSpeed = correctSpeedPerspective(rawSpeed, correctedPos)

		// Apply the filters			
		val index = robotID.ordinal
		val filteredX = xposFilters.get(index).apply(correctedPos.x)
		val filteredY = yposFilters.get(index).apply(correctedPos.y)
		val filteredXspeed = xspeedFilters.get(index).apply(correctedSpeed.x)
		val filteredYspeed = yspeedFilters.get(index).apply(correctedSpeed.y)
		val filteredAngle = angleFilters.get(index).apply(angle)
		val filteredRotSpeed = rotSpeedFilters.get(index).apply(rotSpeed)
		
		// Compute the offset to the axis
		val filteredAngleRad = filteredAngle.toRadians
		val offsetX = ROBOT_MARKER_OFFSET * cos(filteredAngleRad)
		val offsetY = ROBOT_MARKER_OFFSET * sin(filteredAngleRad)

		val robotPosition = new RobotPosition(filteredX - offsetX, filteredY - offsetY,
				Vector.cartesian(filteredXspeed, filteredYspeed),
				minimizeAngle(filteredAngle), filteredRotSpeed)
		synchronized (this) {
			robotPositions.set(index, robotPosition)
			timestamps.set(index, timestamp)
		}
	}
	
	/**
	 * Correct the given position vector to consider the height of the robot.
	 */
	static def Vector correctPositionPerspective(Vector rawPosition) {
		// Apply the perspective correction factor to the center distance
		val d = rawPosition.length * PERSPECTIVE_CORRECTION
		Vector.polar(d, rawPosition.angle)
	}
	
	/**
	 * Correct the given speed vector to consider the height of the robot.
	 */
	static def Vector correctSpeedPerspective(Vector rawSpeed, Vector position) {
		// The angle between the speed vector and the center position
		val angleToCenterRad = toRadians(position.angle - rawSpeed.angle)
		// The speed component parallel to the axis to the center
		val axialSpeed = rawSpeed.length * cos(angleToCenterRad)
		// Apply the perspective correction factor to the axial speed
		val axialVector = Vector.polar(abs(axialSpeed * PERSPECTIVE_CORRECTION), position.angle)
		// The speed component orthogonal to the axis to the center
		val coaxialSpeed = rawSpeed.length * sin(angleToCenterRad)
		val coaxialVector = Vector.polar(abs(coaxialSpeed), position.angle - 90)
		// Combine axial and coaxial speed components to get the result
		axialVector * axialSpeed.signum + coaxialVector * coaxialSpeed.signum
	}
	
	/**
	 * Return the last sample received from the camera server for the given robot.
	 * The sample data are already processed with filtering and perspective correction.
	 */
	def getCameraSample(RobotID robotID) {
		synchronized (this) {
			val ownPosition = robotPositions.get(robotID.ordinal)
			val ownTimestamp = timestamps.get(robotID.ordinal)
			val opponentPosition = robotPositions.get(robotID.opponent.ordinal)
			val opponentTimestamp = timestamps.get(robotID.opponent.ordinal)
			new CameraSample(ownPosition, ownTimestamp, opponentPosition, opponentTimestamp)
		}
	}
	
	/**
	 * A UDP package listener for TUIO.
	 */
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
	
				} else if (command.equals("set") && args.size >= 3) {
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
							if (aliveCommands.get(index) && setComArgs.size >= 9) {
								val float xpos = setComArgs.get(3) as Float
								val float ypos = setComArgs.get(4) as Float
								val float angle = setComArgs.get(5) as Float
								val float xspeed = setComArgs.get(6) as Float
								val float yspeed = setComArgs.get(7) as Float
								val float rotSpeed = setComArgs.get(8) as Float
								client.setRobotPosition(robotID, timestamp, xpos, ypos, angle,
										xspeed, yspeed, rotSpeed)
							}
						]
					}
				}
			}
		}
		
	}
	
}
