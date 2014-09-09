package org.xtext.xrobot.server

import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator
import TUIO.TuioClient
import org.xtext.xrobot.net.CameraView

class RemoteRobotFactory {
	
	val StateReceiver stateReceiver
	
	val SocketChannel socket
	
	val String name
	
	val TuioClient tuioClient
	
	val CameraView cameraView
	
	var boolean isReleased
	
	var RemoteRobot lastRobot
	
	new(String name, SocketChannel socket) {
		this.socket = socket
		this.name = name
		stateReceiver = new StateReceiver(socket)
		stateReceiver.start
		tuioClient = new TuioClient()
		tuioClient.connect
		cameraView = new CameraView(tuioClient)
	}
	
	def getName() {
		name
	}
	
	def void release() {
		if(!isReleased) {
			try {
				tuioClient.disconnect
				try {
					lastRobot?.release
				} catch(Exception e) {}
				stateReceiver.shutdown
				try {
					socket?.close
				} catch(Exception e) {}
			} finally {
				isReleased = true
			}
		}
	}
	
	def isAlive() {
		!isReleased && stateReceiver.isAlive
	}
	
	def newRobot(CancelIndicator cancelIndicator) {
		val nextCommandSerialNr = if(lastRobot != null) lastRobot.nextCommandSerialNr + 10 else 10
		lastRobot = new RemoteRobot(0, nextCommandSerialNr, socket, stateReceiver, cancelIndicator, cameraView)
		lastRobot.waitForUpdate
		lastRobot
	}
}