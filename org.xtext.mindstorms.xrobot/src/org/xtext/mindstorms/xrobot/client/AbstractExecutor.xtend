package org.xtext.mindstorms.xrobot.client

import java.io.DataInputStream
import java.io.DataOutputStream

class AbstractExecutor {
	
	protected DataInputStream input
	
	protected DataOutputStream output
	
	new(DataInputStream input, DataOutputStream output) {
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
				output.flush
				return false
			}
			case -2: {
				output.writeBoolean(true)
				output.flush
			}
			default: {
				println("Illegal messageType " + messageType)
			}
		}
		return true
	}
	
}