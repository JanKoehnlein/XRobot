package org.xtext.mindstorms.xrobot.server

import java.io.DataInputStream
import java.io.DataOutputStream
import java.net.Socket

abstract class AbstractRemoteProxy {
	
	protected Socket socket
	
	protected DataInputStream input
	
	protected DataOutputStream output
	
	protected int componentID
	
	protected new(Socket socket, int componentID) {
		this.socket = socket
		this.input = new DataInputStream(socket.inputStream) 
		this.output = new DataOutputStream(socket.outputStream)
		this.componentID = componentID
	}
	
	def shutdown() {
		output.writeInt(componentID)
		output.writeInt(-1)
		output.flush
		input.readBoolean
		closeSocket
	}
	
	def isAlive() {
		output.writeInt(componentID)
		if(socket != null && socket.closed)
			return false
		output.writeInt(-2)
		output.flush
		input.readBoolean
	}

	def closeSocket() {
		socket?.close
	}
	
}