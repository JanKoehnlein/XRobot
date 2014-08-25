package org.xtext.xrobot.server

import java.nio.channels.SocketChannel
import org.xtext.xrobot.net.INetConfig

class RemoteRobot extends RemoteRobotProxy implements INetConfig {
	
	new(SocketChannel socket, int componentID) {
		super(socket, componentID)
	}
	
	def void shutdown() {
		output.writeInt(componentID)
		output.writeInt(-1)
		output.send
		closeSocket
	}
	
	def void closeSocket() {
		socket ?.close
	}
}