package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.api.RobotSight
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.api.RobotPosition

class RemoteRobot extends RemoteRobotProxy {
	
	val CameraClient cameraClient
	
	val IRobotSightFilter sightFilter
	
	var RobotSight irOpponentPosition
	
	var RobotPosition ownPosition
	
	var RobotPosition opponentPosition

	new(int componentID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
		CancelIndicator cancelIndicator, IRobotSightFilter sightFilter) {
		super(componentID, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
		this.sightFilter = sightFilter
		this.cameraClient = null
	}

	new(int componentID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
		CancelIndicator cancelIndicator, CameraClient cameraView) {
		super(componentID, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
		this.sightFilter = null
		this.cameraClient = cameraView
	}
	
	def waitForUpdate() {
		val lastUpdate = if(state == null) Long.MIN_VALUE else state.getSampleTime();
		var newState = stateProvider.getState();
		var tries = 3 * SOCKET_TIMEOUT / UPDATE_INTERVAL;
		while (newState == null || lastUpdate >= newState.getSampleTime()) {
			checkCanceled()
			if (tries-- <= 0)
				throw new SocketTimeoutException();
			Thread.yield();
			Thread.sleep(UPDATE_INTERVAL / 3);
			newState = stateProvider.getState();
		}
		setState(newState);
	}

	def release() {
		stop
		output.writeInt(componentID)
		output.writeInt(-1)
		output.send
	}
	
	override RobotSight getIRRobotSight() {
		irOpponentPosition
	}
	
	override setState(RobotServerState state) {
		super.setState(state)
		if (sightFilter != null) {
			irOpponentPosition = sightFilter.apply(state.IROpponentPosition)
		}
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
