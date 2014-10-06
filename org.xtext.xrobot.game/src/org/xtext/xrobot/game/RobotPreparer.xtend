package org.xtext.xrobot.game

import org.apache.log4j.Logger
import org.xtext.xrobot.api.Position
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot

import static java.lang.Math.*
import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.api.IArena.*
import static org.xtext.xrobot.game.PlayerStatus.*

import static extension javafx.util.Duration.*

class RobotPreparer {
	
	static val LOG = Logger.getLogger(RobotPreparer)
	
	static double LOW_BATTERY_CHARGE = 0.65
	static double MIN_BATTERY_CHARGE = 0.60
	
	static val DISTANCE_ACCURACY = 5.0
	static val ANGLE_ACCURACY = 8.0
	
	static val PREPARATION_TIMEOUT = 10000
	
	volatile boolean isCanceled = false

	IRemoteRobot robot
	Thread thread
	
	PlayerSlot slot
	
	new(PlayerSlot slot) {
		this.slot = slot
	}
	
	private def getDisplay() {
		slot.display
	}

	def void getReady() {
		LOG.debug(slot.scriptName + ' getReady()')
		slot.status = PREPARING
		isCanceled = false
		if(thread?.isAlive)
			throw new IllegalStateException('RobotPlacer is already running')
		robot = slot.robotFactory.newRobot [isCanceled]
		if(robot.batteryState < MIN_BATTERY_CHARGE) 
			display.showError(slot.scriptName + ': Change battery', 2.seconds)
		if(robot.batteryState < LOW_BATTERY_CHARGE) 
			display.showInfo(slot.scriptName + ': Battery low', 2.seconds)
		thread = new Thread([
			try {
				goHome
			} catch (CanceledException exc) {
				// ignore
			} catch (Exception exc) {
				LOG.error('Error preparing robot', exc)
			}
		], 'RobotPlacer') => [
			daemon = true
		]
		thread.start
	}
	
	def waitReady() {
		LOG.debug(slot.scriptName + ' waitReady()')
		thread?.join(PREPARATION_TIMEOUT)
		isCanceled = true
		thread?.join
		slot.status = checkStatus
	}
	
	private def checkStatus() {
		val isBatteryEmpty = robot.batteryState < MIN_BATTERY_CHARGE 
		val isAtHome = robot.ownPosition.getRelativeDirection(homePosition).distance < DISTANCE_ACCURACY
					&& abs(normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)) < ANGLE_ACCURACY
		var newStatus = READY
		if(!isAtHome) {
			display.showError(slot.scriptName + ': Not at start position', 2.seconds)
			newStatus = NOT_AT_HOME
		}
		if(isBatteryEmpty) {
			display.showError(slot.scriptName + ': Change batteries', 2.seconds)
			newStatus = BATTERY_EXHAUSTED
		} 
		newStatus
	}
	
	private def goHome() {
		robot.rotationSpeed = robot.maxRotationSpeed * 0.7
		robot.drivingSpeed = robot.maxDrivingSpeed

		val homePosition = getHomePosition()
		var direction = robot.ownPosition.getRelativeDirection(homePosition)
		while (direction.distance > DISTANCE_ACCURACY) {
			if (abs(direction.angle) <= ANGLE_ACCURACY) {
				robot.drive(direction.distance)
			} else if (abs(normalizeAngle(direction.angle - 180)) <= ANGLE_ACCURACY) {
				robot.drive(-direction.distance)
			} else if (abs(direction.angle) <= 120) {
				robot.rotate(direction.angle)
			} else {
				robot.rotate(normalizeAngle(direction.angle - 180))
			}
			robot.waitForUpdate
			direction = robot.ownPosition.getRelativeDirection(homePosition)
		}

		val homeViewDirection = getHomeViewDirection()
		var angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		while (abs(angle) > ANGLE_ACCURACY) {
			robot.rotate(angle)
			robot.waitForUpdate
			angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		}
		slot.status = checkStatus
	}
	
	private def getHomeViewDirection() {
		switch robot.robotID {
			case Blue: 180
			case Red: 0
		}
	}
	
	private def getHomePosition() {
		switch robot.robotID {
			case Blue: new Position(-ARENA_OUTER_RADIUS * 0.4, 0)
			case Red: new Position(ARENA_OUTER_RADIUS * 0.4, 0)
		}
	}
	
	private def waitForUpdate(IRemoteRobot robot) {
		Thread.sleep(200)
		robot.waitForUpdate(INetConfig.SOCKET_TIMEOUT)
	}
	
}