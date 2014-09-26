package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.net.INetConfig

import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class RemoteRobotFactory implements INetConfig, IRemoteRobot.Factory {
	
	val RobotID robotID 
	
	val SocketChannel socket
	
	val StateReceiver stateReceiver
	
	val CameraClient cameraClient
	
	var boolean isReleased
	
	var RemoteRobot lastRobot
	
	new(RobotID robotID, SocketChannel socket, CameraClient cameraClient) throws SocketTimeoutException {
		try {
			this.robotID = robotID
			this.socket = socket
			stateReceiver = new StateReceiver(socket)
			stateReceiver.start
			this.cameraClient = cameraClient
		} catch(Exception exc) {
			ignoreExceptions[stateReceiver?.shutdown]
			throw exc
		}
	}
	
	override getRobotID() {
		robotID
	}
	
	override void release() {
		if(!isReleased) {
			ignoreExceptions[lastRobot?.release]
			stateReceiver.shutdown
			ignoreExceptions[socket?.close]
			isReleased = true
		}
	}
	
	override void reset() {
		lastRobot?.reset
	}
	
	override isAlive() {
		!isReleased && stateReceiver.isAlive
	}
	
	override newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException {
		val nextCommandSerialNr = 10
		val timeout = 10 * SOCKET_TIMEOUT
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, stateReceiver, cancelIndicator, cameraClient)
		lastRobot.waitForUpdate(timeout)
		lastRobot
	}
	
	override newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot) {
		val nextCommandSerialNr = lastRobot.nextCommandSerialNr + 10
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, stateReceiver, cancelIndicator, cameraClient)
		val existingRemoteRobot = existingRobot as RemoteRobot
		lastRobot.setState(existingRemoteRobot.state, existingRemoteRobot.cameraSample)
		lastRobot
	}
}
