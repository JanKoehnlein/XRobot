package org.xtext.xrobot.server

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.net.SocketInputBuffer

class StateReceiver extends Thread implements INetConfig {
	
	SocketInputBuffer input

	Selector selector
	
	volatile boolean isStopped = false
	
	long failureCount 
	long successCount
	
	var RobotServerState lastState
	
	new(SocketChannel socket) {
		this.input = new SocketInputBuffer(socket)
		this.selector = Selector.open
		socket.register(selector, SelectionKey.OP_READ)	
		daemon = true
	}

	override run() {
		while(!isStopped) {
			try {
				selector.select(SOCKET_TIMEOUT)
				for(key: selector.selectedKeys) {
					if(key.isReadable) {
						input.receive
						val state = new RobotServerState
						while(input.hasMore) {
							try {
								state.read(input)
								successCount++
							} catch(Exception exc) {
								failureCount++  
							}							
						}
						if(failureCount > 0 && (failureCount + successCount) % 100l == 0) {
							System.err.println('State read failure rate ' + failureCount as double / (failureCount + successCount))
						}
						lastState = state
					} 
				}
			} catch(ClosedSelectorException e) {
				return
			} catch(Exception e) {
				System.err.println(e.message)
				e.printStackTrace
			}
		}
	}

	def getLastState() {
		lastState
	}	
	
	def shutdown() {
		isStopped = true
		join(SOCKET_TIMEOUT)
	}
}