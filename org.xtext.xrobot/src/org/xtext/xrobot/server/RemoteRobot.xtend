package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.camera.CameraClient

class RemoteRobot extends RemoteRobotProxy {
	
	val CameraClient cameraClient
	
	var RobotPosition ownPosition
	
	var RobotPosition opponentPosition

	new(int componentID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
			CancelIndicator cancelIndicator, CameraClient cameraClient) {
		super(componentID, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
		this.cameraClient = cameraClient
	}
	
	def waitForUpdate(int timeout) throws SocketTimeoutException {
		val lastUpdate = if(state == null) Long.MIN_VALUE else state.sampleTime
		var newState = stateProvider.state
		var tries = timeout / UPDATE_INTERVAL;
		while (newState == null || lastUpdate >= newState.sampleTime) {
			checkCanceled
			if (tries-- <= 0)
				throw new SocketTimeoutException('No state update from after ' + timeout + 'ms.')
			Thread.yield
			Thread.sleep(UPDATE_INTERVAL / 3)
			newState = stateProvider.state
		}
		setState(newState)
	}

	def release() {
		stop
		output.writeInt(componentID)
		output.writeInt(-1)
		output.send
	}
	
	override setState(RobotServerState state) {
		super.setState(state)
		if (cameraClient != null) {
			cameraClient.robotPositions.forEach[
				if(robotID.name == name)
					ownPosition = it
				else 
					opponentPosition = it
			]
		}
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
	
	override void update() {
    	setState(stateProvider.state)
  	}
}
