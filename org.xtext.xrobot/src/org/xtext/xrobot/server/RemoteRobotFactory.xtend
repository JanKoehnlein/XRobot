package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class RemoteRobotFactory implements IRemoteRobot.Factory {
	
	val RobotID robotID 
	
	val SocketChannel socket
	
	val writeLock = new Object
	
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
		if (isReleased) {
			throw new IllegalStateException
		}
		val nextCommandSerialNr = 10
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, writeLock, stateReceiver,
				cancelIndicator, cameraClient)
		lastRobot.waitForUpdate(10 * SOCKET_TIMEOUT)
		lastRobot
	}
	
	override newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot) {
		if (isReleased) {
			throw new IllegalStateException
		}
		val nextCommandSerialNr = lastRobot.nextCommandSerialNr + 10
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, writeLock, stateReceiver,
				cancelIndicator, cameraClient)
		val existingRemoteRobot = existingRobot as RemoteRobot
		lastRobot.setState(existingRemoteRobot.state, existingRemoteRobot.cameraSample)
		lastRobot
	}
}
