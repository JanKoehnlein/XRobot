package org.xtext.xrobot.server

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.apache.log4j.Logger
import org.xtext.xrobot.net.SocketInputBuffer

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class StateReceiver implements StateProvider<RobotServerState> {
	
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
		this.thread = new Thread([ run ], 'StateReceiver') => [
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
							synchronized(this) {
								lastState = state
							}
							LOG.debug('Received state ' +  state.sampleTime)
						} catch(Exception exc) {
							failureCount++  
							LOG.error('State read failures ' + failureCount + " successes " + successCount)
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
		synchronized(this) {
			lastState
		}
	}	
	
	def shutdown() {
		isStopped = true
		ignoreExceptions[ thread.join(SOCKET_TIMEOUT) ]
		thread = null
	}
}