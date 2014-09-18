package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.camera.CameraSample

class RemoteRobot extends RemoteRobotProxy {
	
	val CameraClient cameraClient
	
	var CameraSample cameraSample

	val RobotID robotID

	new(RobotID robotID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
			CancelIndicator cancelIndicator, CameraClient cameraClient) {
		super(0, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
		this.robotID = robotID
		this.cameraClient = cameraClient
	}
	
	override getRobotID() {
		robotID
	}

	override getName() {
		robotID.name
	}

	def waitForUpdate(int timeout) throws SocketTimeoutException {
		val lastStateUpdate = if(state == null) Long.MIN_VALUE else state.sampleTime
		var newState = stateProvider.state
		var tries = timeout / UPDATE_INTERVAL;
		while (newState == null || lastStateUpdate >= newState.sampleTime) {
			checkCanceled
			if (tries-- <= 0)
				throw new SocketTimeoutException('No state update from robot after ' + timeout + 'ms.')
			Thread.sleep(UPDATE_INTERVAL / 3)
			newState = stateProvider.state
		}
		
		val lastOwnTimestamp = if (cameraSample == null) Long.MIN_VALUE
				else cameraSample.ownTimestamp
		val lastOpponentTimestamp = if (cameraSample == null) Long.MIN_VALUE
				else cameraSample.opponentTimestamp
		var newCameraSample = cameraClient.getCameraSample(robotID)
		while (newCameraSample.ownPosition == null
				|| newCameraSample.ownTimestamp <= lastOwnTimestamp
				|| newCameraSample.opponentPosition == null
				|| newCameraSample.opponentTimestamp <= lastOpponentTimestamp) {
			checkCanceled
			if (tries-- <= 0)
				throw new SocketTimeoutException('No position update from camera after ' + timeout + 'ms.')
			Thread.sleep(UPDATE_INTERVAL / 3)
			newCameraSample = cameraClient.getCameraSample(robotID)
		}
		
		setState(newState, newCameraSample)
	}

	def release() {
		stop
		output.writeInt(componentID)
		output.writeInt(-1)
		output.send
	}
	
	def setState(RobotServerState state, CameraSample cameraSample) {
		setState(state)
		this.cameraSample = cameraSample		
	}
	
	def getCameraSample() {
		cameraSample
	}
	
	override getOwnPosition() {
		cameraSample.ownPosition
	}
	
	override getOpponentPosition() {
		cameraSample.opponentPosition
	}
	
	override getOpponentDirection() {
		ownPosition.getRelativeDirection(opponentPosition)
	}
	
	override void update() {
    	setState(stateProvider.state, cameraClient.getCameraSample(robotID))
  	}
}
