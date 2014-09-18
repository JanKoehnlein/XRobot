package org.xtext.xrobot.server

import TUIO.TuioClient
import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.net.INetConfig

import static org.xtext.xrobot.util.IgnoreExceptionsExtenision.*

class RemoteRobotFactory implements INetConfig {
	
	val RobotID robotID 
	
	val SocketChannel socket
	
	val StateReceiver stateReceiver
	
	val TuioClient tuioClient
	
	val CameraClient cameraClient
	
	var boolean isReleased
	
	var RemoteRobot lastRobot
	
	new(RobotID robotID, SocketChannel socket) throws SocketTimeoutException {
		try {
			this.robotID = robotID
			this.socket = socket
			stateReceiver = new StateReceiver(socket)
			stateReceiver.start
			tuioClient = new TuioClient()
			tuioClient.connect
			cameraClient = new CameraClient(tuioClient)
		} catch(Exception exc) {
			ignoreExceptions[stateReceiver?.shutdown]
			ignoreExceptions[tuioClient?.disconnect]
			throw exc
		}
	}
	
	def getRobotID() {
		robotID
	}
	
	def void release() {
		if(!isReleased) {
			ignoreExceptions[tuioClient.disconnect]
			ignoreExceptions[lastRobot?.release]
			stateReceiver.shutdown
			ignoreExceptions[socket?.close]
			isReleased = true
		}
	}
	
	def isAlive() {
		!isReleased && stateReceiver.isAlive
	}
	
	def newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException {
		val nextCommandSerialNr = 10
		val timeout = 4 * SOCKET_TIMEOUT
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, stateReceiver, cancelIndicator, cameraClient)
		lastRobot.waitForUpdate(timeout)
		lastRobot
	}
	
	def newRobot(CancelIndicator cancelIndicator, RemoteRobot existingRobot) {
		val nextCommandSerialNr = lastRobot.nextCommandSerialNr + 10
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, stateReceiver, cancelIndicator, cameraClient)
		lastRobot.setState(existingRobot.state, existingRobot.cameraSample)
		lastRobot
	}
	
}
