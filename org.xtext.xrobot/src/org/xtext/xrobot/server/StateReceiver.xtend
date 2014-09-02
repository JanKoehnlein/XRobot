package org.xtext.xrobot.server

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.net.SocketInputBuffer

class StateReceiver implements INetConfig, StateProvider<RobotServerState> {
	
	SocketInputBuffer input

	Selector selector
	
	volatile boolean isStopped = false
	
	long failureCount 
	long successCount
	
	volatile RobotServerState lastState
	
	Thread thread
	
	new(SocketChannel socket) {
		this.input = new SocketInputBuffer(socket)
		this.selector = Selector.open
		socket.register(selector, SelectionKey.OP_READ)	
		this.thread = new Thread [ run ] => [
			daemon = true
		]
	}

	private def run() {
		while(!isStopped) {
			try {
				selector.select(SOCKET_TIMEOUT)
				for(key: selector.selectedKeys) {
					if(key.isReadable) {
						input.receive
						val state = new RobotServerState
						try {
							while(input.hasMore) {
								state.read(input)
								successCount++
							}
							lastState = state
						} catch(Exception exc) {
							failureCount++  
							System.err.println('State read failures ' + failureCount + " succeses " + successCount)
//							System.err.println('State read failure rate ' + failureCount as double / (failureCount + successCount))
						}							
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
	
	def start() {
		thread.start
	}

	def isAlive() {
		thread.alive
	}

	override getState() {
		lastState
	}	
	
	def shutdown() {
		isStopped = true
		thread.join(SOCKET_TIMEOUT)
	}
}