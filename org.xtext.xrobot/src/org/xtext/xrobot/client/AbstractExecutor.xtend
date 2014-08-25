package org.xtext.xrobot.client

import java.io.IOException
import org.xtext.xrobot.net.SocketInputBuffer

abstract class AbstractExecutor {
	
	protected SocketInputBuffer input
	
	new(SocketInputBuffer input) {
		this.input = input
	}
	
	def dispatchAndExecute() throws IOException {
		val componentID = input.readInt
		val subComponent = getSubComponent(componentID)
		if(subComponent != null)
			return subComponent.executeNext
		else
			return true
	}
	
	abstract def AbstractExecutor getSubComponent(int comonentID)
	
	protected def boolean executeNext() {
		val messageType = input.readInt
//		println(messageType)
		execute(messageType);
	}

	protected def execute(int messageType) {
		switch messageType {
			case -1: 
				return false
			default: {
				println("Illegal messageType " + messageType)
			}
		}
		return true
	}
	
}