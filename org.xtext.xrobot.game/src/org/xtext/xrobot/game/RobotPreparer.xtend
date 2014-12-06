/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import com.google.inject.Inject
import java.net.SocketTimeoutException
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.camera.CameraTimeoutException
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.util.EmptyBatteriesException

import static java.lang.Math.*
import static org.xtext.xrobot.api.GeometryExtensions.*
import static org.xtext.xrobot.api.IRobot.*
import static org.xtext.xrobot.game.PlayerStatus.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.ignoreExceptions

import static extension javafx.util.Duration.*

class RobotPreparer implements IRobotPreparer {
	
	static val LOG = Logger.getLogger(RobotPreparer)
	
	static double LOW_BATTERY_CHARGE = 0.80
	static double MIN_BATTERY_CHARGE = 0.70
	
	static val DISTANCE_ACCURACY = 4.0
	static val ANGLE_ACCURACY = 6.0
	static val MAX_PLACEMENT_MOVES = 6
	static val MESSAGE_DURATION = 5
	
	static val PREPARATION_TIMEOUT = 10000
	
	volatile boolean isCanceled = false

	IRemoteRobot robot
	
	Thread thread
	
	val statusLock = new Object
	
	volatile long lastStatusMessage
	
	@Accessors(PUBLIC_SETTER)
	PlayerSlot slot

	@Inject IErrorReporter errorReporter

	override prepare() {
		LOG.debug(slot.robotID + ' prepare()')
		if (slot.status != READY && !thread?.isAlive) {
			slot.status = PREPARING
			isCanceled = false
			robot = slot.robotFactory.newRobot[isCanceled]
			LOG.info(slot.robotID + ' battery ' + round(robot.batteryState * 100) + '%')
			if (robot.batteryState < MIN_BATTERY_CHARGE)
				throw new EmptyBatteriesException('Change batteries for ' + slot.robotID + ' robot')
			else if (robot.batteryState < LOW_BATTERY_CHARGE)
				checkAndShowError(slot.robotID + ' robot: Battery low')
			thread = new Thread([
				try {
					robot.invincible = true
					robot.reset
					goHome
					robot.calibrateScoop
				} catch (CanceledException exc) {
					// ignore
				} catch (CameraTimeoutException cte) {
					LOG.info(cte.message)
					slot.status = NO_CAMERA
				} catch (SocketTimeoutException ste) {
					LOG.warn(ste.message)
					slot.status = NO_CONNECTION
				} catch (Exception exc) {
					LOG.error('Error preparing robot', exc)
				} finally {
					ignoreExceptions[ robot.invincible = false ]
					synchronized (statusLock) {
						slot.status = checkStatus
					}
				}
			], 'RobotPlacer') => [
				daemon = true
			]
			thread.start
		}
	}
	
	override waitReady() {
		LOG.debug(slot.robotID + ' waitReady()')
		thread?.join(PREPARATION_TIMEOUT)
		isCanceled = true
		thread?.join
		synchronized (statusLock) {
			slot.status = checkStatus
		}
	}
	
	override cancel() {
		isCanceled = true
		thread?.join(1000)
	}
	
	private def checkStatus() {
		var newStatus = READY
		if (slot.status == NO_CAMERA || slot.status == NO_CONNECTION) {
			newStatus = slot.status
		} else if (slot.available) {
			// The slot has been released during preparation
			newStatus = AVAILABLE
		} else if (robot == null) {
			checkAndShowError(slot.robotID + ' robot could not be located')
			newStatus = NOT_AT_HOME
		} else if (robot.batteryState < MIN_BATTERY_CHARGE ) {
			checkAndShowError('Change batteries for ' + slot.robotID + ' robot')
			newStatus = BATTERY_EXHAUSTED
		} else {
			val isAtHome = robot.ownPosition.getRelativePosition(homePosition).length < DISTANCE_ACCURACY
						&& abs(minimizeAngle(homeViewDirection - robot.ownPosition.viewDirection)) < ANGLE_ACCURACY
			if (!isAtHome) {
				checkAndShowError(slot.robotID + ' robot is not at start position')
				newStatus = NOT_AT_HOME
			}
		} 
		newStatus
	}
	
	private def checkAndShowError(String message) {
		val currentTime = System.currentTimeMillis
		if (currentTime - lastStatusMessage > MESSAGE_DURATION * 1000) {
			lastStatusMessage = currentTime
			errorReporter.showError(message, MESSAGE_DURATION.seconds)
		}
	}
	
	private def goHome() {
		val homePosition = getHomePosition()
		var direction = robot.ownPosition.getRelativePosition(homePosition)
		var moveCount = 0
		while (direction.length > DISTANCE_ACCURACY - 1 && moveCount++ < MAX_PLACEMENT_MOVES) {
			if (abs(direction.angle) <= ANGLE_ACCURACY + 2) {
				robot.setAndDrive(direction.length)
			} else if (abs(minimizeAngle(direction.angle - 180)) <= ANGLE_ACCURACY + 2) {
				robot.setAndDrive(-direction.length)
			} else if (abs(direction.angle) <= 120) {
				robot.setAndRotate(direction.angle)
			} else {
				robot.setAndRotate(minimizeAngle(direction.angle - 180))
			}
			robot.waitForUpdate
			direction = robot.ownPosition.getRelativePosition(homePosition)
		}

		val homeViewDirection = getHomeViewDirection()
		var angle = minimizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		moveCount = 0
		while (abs(angle) > ANGLE_ACCURACY - 2 && moveCount++ < MAX_PLACEMENT_MOVES / 2) {
			robot.setAndRotate(angle)
			robot.waitForUpdate
			angle = minimizeAngle(homeViewDirection - robot.ownPosition.viewDirection)
		}
	}
	
	private def getHomeViewDirection() {
		switch robot.robotID {
			case Blue: 180.0
			case Red: 0.0
		}
	}
	
	private def getHomePosition() {
		switch robot.robotID {
			case Blue: Vector.cartesian(-ARENA_OUTER_RADIUS * 0.38, 0)
			case Red: Vector.cartesian(ARENA_OUTER_RADIUS * 0.38, 0)
		}
	}
	
	private def setAndDrive(IRemoteRobot robot, double distance) {
		if (abs(distance) > 20)
			robot.drivingSpeed = robot.maxDrivingSpeed
		else
			robot.drivingSpeed = (0.5 + 0.5 * abs(distance) / 20) * robot.maxDrivingSpeed
		robot.drive(distance)
	}
	
	private def setAndRotate(IRemoteRobot robot, double angle) {
		if (abs(angle) > 90)
			robot.rotationSpeed = robot.maxRotationSpeed
		else
			robot.rotationSpeed = (0.4 + 0.6 * abs(angle) / 90) * robot.maxRotationSpeed
		robot.rotate(angle)
	}
	
	private def waitForUpdate(IRemoteRobot robot) {
		Thread.sleep(200)
		robot.waitForUpdate(INetConfig.SOCKET_TIMEOUT)
	}
	
}
