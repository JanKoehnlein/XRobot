package org.xtext.xrobot.client

import java.io.IOException
import org.xtext.xrobot.net.SocketInputBuffer
import org.apache.log4j.Logger

abstract class AbstractExecutor {
	
	static val LOG = Logger.getLogger(AbstractExecutor)
	
	protected SocketInputBuffer input
	
	new(SocketInputBuffer input) {
		this.input = input
	}
	
	def dispatchAndExecute() throws IOException {
		val componentID = input.readInt
		LOG.debug('componentID=' + componentID)
		val subComponent = getSubComponent(componentID)
		if(subComponent != null)
			return subComponent.executeNext
		else
			return true
	}
	
	abstract def AbstractExecutor getSubComponent(int comonentID)
	
	protected def boolean executeNext() {
		val messageType = input.readInt
		LOG.debug('messageType=' + messageType)
		execute(messageType)
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