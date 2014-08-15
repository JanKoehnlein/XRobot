package org.xtext.mindstorms.xrobot.server

import java.io.DataInputStream
import java.io.DataOutputStream
import java.net.Socket

abstract class AbstractRemoteProxy {
	
	Socket socket
	
	protected DataInputStream input
	
	protected DataOutputStream output
	
	protected new(Socket clientSocket) {
		this.input = new DataInputStream(clientSocket.inputStream) 
		this.output = new DataOutputStream(clientSocket.outputStream)
	}
	
	def shutdown() {
		output.writeInt(-1)
		output.flush
		input.readBoolean
		closeSocket
	}
	
	def isAlive() {
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