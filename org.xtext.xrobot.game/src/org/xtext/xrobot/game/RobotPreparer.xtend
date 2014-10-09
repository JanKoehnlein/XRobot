package org.xtext.xrobot.game

import com.google.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.api.Position
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot

import static java.lang.Math.*
import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.api.IArena.*
import static org.xtext.xrobot.game.PlayerStatus.*

import static extension javafx.util.Duration.*

class RobotPreparer implements IRobotPreparer {
	
	static val LOG = Logger.getLogger(RobotPreparer)
	
	static double LOW_BATTERY_CHARGE = 0.65
	static double MIN_BATTERY_CHARGE = 0.60
	
	static val DISTANCE_ACCURACY = 5.0
	static val ANGLE_ACCURACY = 8.0
	static val MAX_PLACEMENT_MOVES = 5
	
	static val PREPARATION_TIMEOUT = 10000
	
	volatile boolean isCanceled = false

	IRemoteRobot robot
	Thread thread
	
	@Accessors(PUBLIC_SETTER)
	PlayerSlot slot

	@Inject IErrorReporter errorReporter

	override prepare() {
		LOG.debug(slot.robotID + ' getReady()')
		LOG.debug(slot.robotID + ' getReady()')
		if(thread?.isAlive) 
			return;
		slot.status = PREPARING
		isCanceled = false
		robot = slot.robotFactory.newRobot [isCanceled]
		LOG.info(slot.robotID + ' battery ' + robot.batteryState)
		if(robot.batteryState < MIN_BATTERY_CHARGE) 
			errorReporter.showError(slot.robotID + ': Change battery', 5.seconds)
		if(robot.batteryState < LOW_BATTERY_CHARGE) 
			errorReporter.showInfo(slot.robotID + ': Battery low', 5.seconds)
		thread = new Thread([
			try {
				robot.invincible = true
				goHome
				robot.invincible = false
			} catch (CanceledException exc) {
				// ignore
			} catch (Exception exc) {
				LOG.error('Error preparing robot', exc)
			} finally {
				slot.status = checkStatus
			}
		], 'RobotPlacer') => [
			daemon = true
		]
		thread.start
	}
	
	override waitReady() {
		LOG.debug(slot.robotID + ' waitReady()')
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
			errorReporter.showError(slot.robotID + ': Not at start position', 5.seconds)
			newStatus = NOT_AT_HOME
		}
		if(isBatteryEmpty) {
			errorReporter.showError(slot.robotID + ': Change batteries', 5.seconds)
			newStatus = BATTERY_EXHAUSTED
		} 
		newStatus
	}
	
	private def goHome() {
		robot.rotationSpeed = robot.maxRotationSpeed * 0.7
		robot.drivingSpeed = robot.maxDrivingSpeed

		val homePosition = getHomePosition()
		var direction = robot.ownPosition.getRelativeDirection(homePosition)
		var moveCount = 0
		while (direction.distance > DISTANCE_ACCURACY && moveCount++ < MAX_PLACEMENT_MOVES) {
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
		moveCount = 0
		while (abs(angle) > ANGLE_ACCURACY && moveCount++ < MAX_PLACEMENT_MOVES) {
			robot.rotate(angle)
			robot.waitForUpdate
			angle = normalizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		}
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