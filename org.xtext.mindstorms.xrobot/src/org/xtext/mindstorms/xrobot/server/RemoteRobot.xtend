package org.xtext.mindstorms.xrobot.server

import java.nio.channels.SocketChannel
import org.xtext.mindstorms.xrobot.net.INetConfig

class RemoteRobot extends RemoteRobotProxy implements INetConfig {
	
	new(SocketChannel socket, int componentID) {
		super(socket, componentID)
	}
	
	def void waitForUpdate() {
		val last = state.sampleTime
		while(state.sampleTime == last)
			Thread.sleep(UPDATE_INTERVAL / 2)
	}
	
}