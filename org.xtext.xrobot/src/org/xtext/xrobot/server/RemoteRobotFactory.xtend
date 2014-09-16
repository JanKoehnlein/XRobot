package org.xtext.xrobot.server

import TUIO.TuioClient
import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.camera.CameraClient
import java.net.SocketTimeoutException
import static org.xtext.xrobot.util.IgnoreExceptionsExtenision.*
import org.xtext.xrobot.net.INetConfig

class RemoteRobotFactory implements INetConfig {
	
	val StateReceiver stateReceiver
	
	val SocketChannel socket
	
	val String name
	
	val TuioClient tuioClient
	
	val CameraClient cameraClient
	
	var boolean isReleased
	
	var RemoteRobot lastRobot
	
	new(String name, SocketChannel socket) throws SocketTimeoutException {
		try {
			this.socket = socket
			this.name = name
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
	
	def getName() {
		name
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
		var nextCommandSerialNr = 10
		var timeout = 4 * SOCKET_TIMEOUT
		if(lastRobot != null) {
			nextCommandSerialNr = lastRobot.nextCommandSerialNr + 10
			timeout = SOCKET_TIMEOUT
		}
		lastRobot = new RemoteRobot(0, nextCommandSerialNr, socket, stateReceiver, cancelIndicator, cameraClient)
		lastRobot.waitForUpdate(timeout)
		lastRobot
	}
}