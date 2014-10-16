package org.xtext.xrobot.server

import com.google.common.base.Predicates
import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.Sample
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.camera.CameraSample
import org.xtext.xrobot.camera.CameraTimeoutException
import org.xtext.xrobot.util.AudioService

import static org.xtext.xrobot.net.INetConfig.*

final class RemoteRobot extends RemoteRobotProxy implements IRemoteRobot {
	
	static val MAX_POSITION_AGE = 500
	static val RELEASE_MESSAGE = -1
	
	val CameraClient cameraClient
	
	var CameraSample cameraSample

	val RobotID robotID
	
	extension AudioService = AudioService.getInstance 

	protected new(RobotID robotID, int nextCommandSerialNr, SocketChannel socket,
			Object writeLock, StateProvider<RobotServerState> stateProvider,
			CancelIndicator cancelIndicator, CameraClient cameraClient) {
		super(0, nextCommandSerialNr, socket, writeLock, stateProvider, cancelIndicator)
		this.robotID = robotID
		this.cameraClient = cameraClient
	}
	
	override getRobotID() {
		robotID
	}

	override waitForUpdate(int timeout) throws SocketTimeoutException {
		val lastStateUpdate = if (state == null) 0 else state.sampleTime
		var newState = stateProvider.state
		var tries = timeout / UPDATE_INTERVAL;
		while (newState == null || lastStateUpdate >= newState.sampleTime) {
			checkCanceled
			if (tries-- <= 0) {
				throw new SocketTimeoutException('No state update from robot after ' + timeout + 'ms.')
			}
			Thread.sleep(UPDATE_INTERVAL)
			newState = stateProvider.state
		}
		
		var newCameraSample = cameraClient.getCameraSample(robotID)
		while (!isValid(newCameraSample)) {
			checkCanceled
			if (tries-- <= 0) {
				newState = stateProvider.state
				setState(newState)
				// Check whether the robot is dead, don't throw an exception in this case
				if (newState.dead) {
					return
				}
				throw new CameraTimeoutException('No position update from camera after ' + timeout + 'ms.')
			}
			Thread.sleep(UPDATE_INTERVAL)
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

	override release() {
		stop
		output.writeInt(componentID)
		output.writeInt(RELEASE_MESSAGE)
    	var commandSerialNr = nextCommandSerialNr++
    	output.writeInt(commandSerialNr)
    	output.send
	    waitFinished(commandSerialNr, Predicates.alwaysFalse)
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
	
	override getOpponentBearing() {
		ownPosition.getRelativePosition(opponentPosition.toVector)
	}
	
	override getCenterBearing() {
		val negOwnPos = -ownPosition.toVector
		Vector.polar(negOwnPos.length, negOwnPos.angle - ownPosition.viewDirection)
	}
	
	override void update() {
    	setState(stateProvider.state, cameraClient.getCameraSample(robotID))
  	}
  	
	override play(Sample sample) {
		sample.play(robotID)
	}
	
	override say(String text) {
		text.speak(robotID)
	}
}
