package org.xtext.xrobot.server

import java.nio.channels.SocketChannel
import org.xtext.xrobot.net.INetConfig
import java.net.SocketTimeoutException

class RemoteRobot extends RemoteRobotProxy implements INetConfig {
	
	StateReceiver stateReceiver
	
	boolean isReleased
	
	new(SocketChannel socket, int componentID) throws SocketTimeoutException {
		super(socket, componentID)
		stateReceiver = new StateReceiver(socket)
		stateReceiver.start
	}
	
	def waitForUpdate(int timeout) throws SocketTimeoutException {
		val lastUpdate = if(state == null) 
				Long.MIN_VALUE
			else 
				state.sampleTime
		var newState = stateReceiver.lastState
		var tries = 3 * timeout / UPDATE_INTERVAL
		while(newState == null || lastUpdate >= newState.sampleTime) {
			if(tries-- <= 0)
				throw new SocketTimeoutException
			Thread.sleep(UPDATE_INTERVAL / 3)
			newState = stateReceiver.lastState
		}
		state = newState 
	}
	
	def void release() {
		if(!isReleased) {
			try {
				stop
				try {
					output.writeInt(componentID)
					output.writeInt(-1)
					output.send
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
}