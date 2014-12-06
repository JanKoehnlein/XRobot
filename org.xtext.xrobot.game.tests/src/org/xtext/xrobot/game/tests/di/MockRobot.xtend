/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import com.google.common.base.Predicate
import java.net.SocketTimeoutException
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.api.Sample
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.camera.CameraTimeoutException
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobot
import org.xtext.xrobot.util.AudioService

import static extension java.lang.Math.*

final class MockRobot implements IRemoteRobot {

	@Accessors(PUBLIC_GETTER)
	val RobotID robotID

	val CancelIndicator cancelIndicator

	val Predicate<MockRobot> deadPredicate
	
	val Predicate<MockRobot> blindPredicate

	RobotPosition ownPosition

	RobotPosition opponentPosition

	@Accessors
	double drivingSpeed

	@Accessors
	double rotationSpeed
	
	boolean isInvincible
	
	long creationTime

	extension AudioService = AudioService.getInstance
	
	new(RobotID robotID, CancelIndicator cancelIndicator, Predicate<MockRobot> deadPredicate,
			Predicate<MockRobot> blindPredicate) {
		this.robotID = robotID
		this.cancelIndicator = cancelIndicator
		this.deadPredicate = deadPredicate
		this.blindPredicate = blindPredicate
		this.ownPosition = new RobotPosition(0, 0, Vector.cartesian(0, 0), 0, 0)
		this.opponentPosition = new RobotPosition(0, 0, Vector.cartesian(0, 0), 0, 0)
		this.creationTime = System.currentTimeMillis
	}
	
	def setState(MockRobot other) {
		this.creationTime = other.creationTime
		this.drivingSpeed = other.drivingSpeed
		this.rotationSpeed = other.rotationSpeed
		this.ownPosition = other.ownPosition
		this.opponentPosition = other.opponentPosition
	}
	
	def getAge() {
		System.currentTimeMillis - creationTime
	}

	override waitForUpdate(int timeout) throws SocketTimeoutException {
		checkCanceled
		if (blindPredicate.apply(this)) {
			Thread.sleep(timeout)
			throw new CameraTimeoutException(robotID, 'No position update from camera after ' + timeout + 'ms.')
		} else {
			Thread.sleep(INetConfig.UPDATE_INTERVAL)
		}
	}

	override release() {
		checkCanceled
	}

	override getBatteryState() {
		0.64
	}

	override startMotors(double leftSpeed, double rightSpeed) {
		checkCanceled
	}

	override drive(double distance) {
		checkCanceled
		ownPosition = new RobotPosition(
			ownPosition.x + distance * cos(ownPosition.viewDirection.toRadians),
			ownPosition.y + distance * sin(ownPosition.viewDirection.toRadians),
			Vector.cartesian(0, 0),
			ownPosition.viewDirection, 0
		)
		Thread.sleep(Math.round(1000 * distance / drivingSpeed))
	}

	override driveForward() {
		checkCanceled
	}

	override driveBackward() {
		checkCanceled
	}
	
	override getMaxDrivingSpeed() {
		return 30
	}

	override rotate(double angle) {
		checkCanceled
		ownPosition = new RobotPosition(
			ownPosition.x,
			ownPosition.y,
			Vector.cartesian(0, 0),
			ownPosition.viewDirection + angle, 0
		)
		Thread.sleep(Math.round(1000 * abs(angle) / rotationSpeed))
	}

	override rotateLeft() {
		checkCanceled
	}

	override rotateRight() {
		checkCanceled
	}

	override getMaxRotationSpeed() {
		return 360
	}

	override curveForward(double radius, double angle) {
		checkCanceled
	}

	override curveBackward(double radius, double angle) {
		checkCanceled
	}

	override curveTo(double distance, double angle) {
		checkCanceled
	}

	override isMoving() {
		checkCanceled
		false
	}

	override stop() {
		checkCanceled
	}

	override reset() {
		checkCanceled
	}

	override scoop(double angle) {
		checkCanceled
	}
	
	override calibrateScoop() {
	}

	override play(Sample sample) {
		sample.play(robotID)
	}

	override say(String text) {
		text.speak(robotID)
	}
	
	override sleep(int milliseconds) {
		if (milliseconds > 0) {
			Thread.sleep(Math.min(milliseconds, RemoteRobot.MAX_SLEEP_TIME))
		}
	}

	override update() {
		checkCanceled
	}

	override getOwnPosition() {
		ownPosition
	}

	override getOpponentPosition() {
		opponentPosition
	}

	override getOpponentBearing() {
		ownPosition.getRelativePosition(opponentPosition.toVector)
	}
	
	override getCenterBearing() {
		val negOwnPos = -ownPosition.toVector
		Vector.polar(negOwnPos.length, negOwnPos.angle - ownPosition.viewDirection)
	}

	private def checkCanceled() {
		if (cancelIndicator.isCanceled)
			throw new CanceledException
	}
	
	override getGroundColor() {
		0.6
	}
	
	override isDead() {
		!isInvincible && deadPredicate.apply(this)
	}
	
	override setInvincible(boolean invincible) {
		this.isInvincible = invincible
	}
	
}
