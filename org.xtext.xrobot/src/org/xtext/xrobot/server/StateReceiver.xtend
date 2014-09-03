package org.xtext.xrobot.server

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.net.SocketInputBuffer
import org.apache.log4j.Logger

class StateReceiver implements INetConfig, StateProvider<RobotServerState> {
	
	static val LOG = Logger.getLogger(StateReceiver)
	
	SocketInputBuffer input

	Selector selector
	
	volatile boolean isStopped = false
	
	long failureCount 
	long successCount
	
	volatile RobotServerState lastState
	
	Thread thread
	
	int packetSize = -1
	
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
							while(input.available >= packetSize) {
								if(packetSize > 0) {
									state.read(input)
								} else {
									val before = input.available
									state.read(input)
									packetSize = before - input.available
								} 
								successCount++
							}
							lastState = state
						} catch(Exception exc) {
							failureCount++  
							LOG.error('State read failures ' + failureCount + " succeses " + successCount)
//							LOG.error('State read failure rate ' + failureCount as double / (failureCount + successCount))
						}							
					} 
				}
			} catch(ClosedSelectorException e) {
				return
			} catch(Exception e) {
				LOG.error(e.message)
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