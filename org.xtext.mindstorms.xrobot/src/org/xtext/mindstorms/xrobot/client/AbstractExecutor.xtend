package org.xtext.mindstorms.xrobot.client

import org.xtext.mindstorms.xrobot.net.SocketInputBuffer
import org.xtext.mindstorms.xrobot.net.SocketOutputBuffer

class AbstractExecutor {
	
	protected SocketInputBuffer input
	
	protected SocketOutputBuffer output
	
	new(SocketInputBuffer input, SocketOutputBuffer output) {
		this.input = input
		this.output = output
	}
	
	def boolean executeNext() {
		val messageType = input.readInt
//		println(messageType)
		execute(messageType);
	}
	
	protected def execute(int messageType) {
		switch messageType {
			case -1: {
				output.writeBoolean(true)
				output.send
				return false
			}
			case -2: {
				output.writeBoolean(true)
				output.send
			}
			default: {
				println("Illegal messageType " + messageType)
			}
		}
		return true
	}
	
}