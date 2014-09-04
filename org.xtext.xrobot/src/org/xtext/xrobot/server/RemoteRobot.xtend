package org.xtext.xrobot.server

import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import java.net.SocketTimeoutException
import org.xtext.xrobot.api.RobotSight

class RemoteRobot extends RemoteRobotProxy {
	
	val IRobotSightFilter sightFilter = new AveragingFilter as IRobotSightFilter
	var RobotSight currentSight

	new(int componentID, int nextCommandSerialNr, SocketChannel socket, StateProvider<RobotServerState> stateProvider,
		CancelIndicator cancelIndicator) {
		super(componentID, nextCommandSerialNr, socket, stateProvider, cancelIndicator)
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
		currentSight = sightFilter.apply(state.opponentPosition)
	}
	
}
