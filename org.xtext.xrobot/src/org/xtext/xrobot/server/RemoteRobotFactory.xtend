package org.xtext.xrobot.server

import java.nio.channels.SocketChannel
import org.eclipse.xtext.util.CancelIndicator

class RemoteRobotFactory {
	
	StateReceiver stateReceiver
	
	boolean isReleased
	
	SocketChannel socket
	
	RemoteRobot lastRobot
	
	String name
	
	new(String name, SocketChannel socket) {
		this.socket = socket
		stateReceiver = new StateReceiver(socket)
		stateReceiver.start
	}
	
	def getName() {
		name
	}
	
	def void release() {
		if(!isReleased) {
			try {
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
		lastRobot = new RemoteRobot(0, nextCommandSerialNr, socket, stateReceiver, cancelIndicator)
		lastRobot.waitForUpdate
		lastRobot
	}
}