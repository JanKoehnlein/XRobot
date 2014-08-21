package org.xtext.mindstorms.xrobot.server

import java.nio.channels.SocketChannel
import org.xtext.mindstorms.xrobot.net.SocketInputBuffer
import org.xtext.mindstorms.xrobot.net.SocketOutputBuffer

abstract class AbstractRemoteProxy {
	
	protected SocketChannel socket
	
	protected SocketInputBuffer input
	
	protected SocketOutputBuffer output
	
	protected int componentID
	
	protected new(SocketChannel socket, int componentID) {
		this.socket = socket
		this.input = new SocketInputBuffer(socket) 
		this.output = new SocketOutputBuffer(socket)
		this.componentID = componentID
	}
	
	def shutdown() {
		output.writeInt(componentID)
		output.writeInt(-1)
		output.send
		closeSocket
	}
	
	def closeSocket() {
		socket?.close
	}
	
}