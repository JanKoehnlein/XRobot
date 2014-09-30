package org.xtext.xrobot.server.testing

import java.net.SocketTimeoutException
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.Direction
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot

import static org.xtext.xrobot.api.GeometryExtensions.*
import static extension java.lang.Math.*

@Accessors
class MockRobot implements IRemoteRobot {

	val RobotID robotID

	val CancelIndicator cancelIndicator

	RobotPosition ownPosition

	RobotPosition opponentPosition

	double travelSpeed

	double rotateSpeed

	new(RobotID robotID, CancelIndicator cancelIndicator) {
		this.robotID = robotID
		this.cancelIndicator = cancelIndicator
		this.ownPosition = new RobotPosition(0, 0, robotID, 0)
		this.opponentPosition = new RobotPosition(0, 0, robotID.opponent, 0)
	}

	override waitForUpdate(int timeout) throws SocketTimeoutException {
		checkCanceled
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

	override forward(double distance) {
		checkCanceled
		ownPosition = new RobotPosition(
			ownPosition.x + distance * cos(ownPosition.viewDirection.toRadians),
			ownPosition.y + distance * sin(ownPosition.viewDirection.toRadians),
			robotID,
			ownPosition.viewDirection
		)
	}

	override forward() {
		checkCanceled
	}

	override backward(double distance) {
		checkCanceled
		ownPosition = new RobotPosition(
			ownPosition.x - distance * cos(ownPosition.viewDirection.toRadians),
			ownPosition.y - distance * sin(ownPosition.viewDirection.toRadians),
			robotID,
			ownPosition.viewDirection
		)
	}

	override backward() {
		checkCanceled
	}

	override getMaxTravelSpeed() {
		return 500
	}

	override rotate(double angle) {
		checkCanceled
		ownPosition = new RobotPosition(
			ownPosition.x,
			ownPosition.y,
			robotID,
			ownPosition.viewDirection + angle
		)
	}

	override rotateLeft() {
		checkCanceled
	}

	override rotateRight() {
		checkCanceled
	}

	override getMaxRotateSpeed() {
		return 500
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

	override playSample(String fileName) {
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

	override getOpponentDirection() {
		ownPosition.getRelativeDirection(opponentPosition)
	}

	override getCenterDirection() {
		val negOwnDirection = (-ownPosition).toDirection
		new Direction(
			negOwnDirection.distance,
			normalizeAngle(negOwnDirection.angle - ownPosition.viewDirection)
		)
	}

	override getLeftMotor() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override getRightMotor() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override getScoopMotor() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	private def checkCanceled() {
		if (cancelIndicator.isCanceled)
			throw new CanceledException
	}
}
