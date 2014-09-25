package org.xtext.xrobot.server.testing

import java.net.SocketTimeoutException
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraSample
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RobotServerState

@Accessors	
class MockRobot implements IRemoteRobot {
	
	RobotID robotID 

	RobotServerState state
	
	double travelSpeed
	 
	double rotateSpeed
	
	CameraSample cameraSample

	new(RobotID id) {
		this.robotID = robotID
		this.state = new RobotServerState
	}
	
	override waitForUpdate(int timeout) throws SocketTimeoutException {
	}
	
	override release() {
	}
	
	override getBatteryState() {
		return state.batteryState
	}
	
	override setState(RobotServerState state, CameraSample cameraSample) {
		this.state = state
		this.cameraSample = cameraSample
	}
	
	override getName() {
		robotID.name
	}
	
	override getRobotID() {
		robotID
	}
	
	override setSpeeds(double leftSpeed, double rightSpeed) {
	}
	
	override forward(double distance) {
	}
	
	override forward() {
	}
	
	override backward(double distance) {
	}
	
	override backward() {
	}
	
	override getMaxTravelSpeed() {
		return 500
	}
	
	override rotate(double angle) {
	}
	
	override rotateLeft() {
	}
	
	override rotateRight() {
	}
	
	override getMaxRotateSpeed() {
		return 500
	}
	
	override curveForward(double radius, double angle) {
	}
	
	override curveBackward(double radius, double angle) {
	}
	
	override curveTo(double distance, double angle) {
	}
	
	override isMoving() {
		false
	}
	
	override stop() {
	}
	
	override reset() {
	}
	
	override scoop(double angle) {
	}
	
	override playSample(String fileName) {
	}
	
	override update() {
	}
	
	override getOwnPosition() {
		cameraSample.ownPosition
	}
	
	override getOpponentPosition() {
		cameraSample.opponentPosition
	}
	
	override getOpponentDirection() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getCenterDirection() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
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
	
	
}