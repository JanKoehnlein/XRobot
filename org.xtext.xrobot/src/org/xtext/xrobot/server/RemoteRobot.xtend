package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.camera.CameraSample

class RemoteRobot extends RemoteRobotProxy {
	
	static val MAX_POSITION_AGE = 500
	
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
		val updateInterval = UPDATE_INTERVAL / 3
		val lastStateUpdate = if (state == null) 0 else state.sampleTime
		var newState = stateProvider.state
		var tries = timeout / updateInterval;
		while (newState == null || lastStateUpdate >= newState.sampleTime) {
			checkCanceled
			if (tries-- <= 0)
				throw new SocketTimeoutException('No state update from robot after ' + timeout + 'ms.')
			Thread.sleep(updateInterval)
			newState = stateProvider.state
		}
		
		var newCameraSample = cameraClient.getCameraSample(robotID)
		while (!isValid(newCameraSample)) {
			checkCanceled
			if (tries-- <= 0)
				throw new SocketTimeoutException('No position update from camera after ' + timeout + 'ms.')
			Thread.sleep(updateInterval)
			newCameraSample = cameraClient.getCameraSample(robotID)
		}
		
		setState(newState, newCameraSample)
	}
	
	private def isValid(CameraSample newSample) {
		val lastOwnTimestamp = if (cameraSample == null) 0
				else cameraSample.ownTimestamp
		val lastOpponentTimestamp = if (cameraSample == null) 0
				else cameraSample.opponentTimestamp
		val currentTime = System.currentTimeMillis
		return newSample.ownPosition != null
			&& newSample.ownTimestamp > lastOwnTimestamp
			&& currentTime - newSample.ownTimestamp <= MAX_POSITION_AGE
			&& newSample.opponentPosition != null
			&& newSample.opponentTimestamp > lastOpponentTimestamp
			&& currentTime - newSample.opponentTimestamp <= MAX_POSITION_AGE
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
