package org.xtext.xrobot.server

import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import java.net.SocketTimeoutException
import org.xtext.xrobot.api.RobotSight
import org.xtext.xrobot.net.CameraView

class RemoteRobot extends RemoteRobotProxy {
	
	val IRobotSightFilter sightFilter
	val CameraView cameraView
	var RobotSight currentSight

	new(int componentID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
		CancelIndicator cancelIndicator, IRobotSightFilter sightFilter) {
		super(componentID, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
		this.sightFilter = sightFilter
		this.cameraView = null
	}

	new(int componentID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
		CancelIndicator cancelIndicator, CameraView cameraView) {
		super(componentID, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
		this.sightFilter = null
		this.cameraView = cameraView
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
	
	override RobotSight getRobotSight() {
		currentSight
	}
	
	override setState(RobotServerState state) {
		super.setState(state)
		if (sightFilter != null) {
			currentSight = sightFilter.apply(state.opponentPosition)
		} else if (cameraView != null) {
			currentSight = cameraView.getRobotSight(this)
		}
	}
	
	override void update() {
    	setState(stateProvider.state)
  	}
}
