/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.server

import java.net.SocketException
import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.apache.log4j.Logger
import org.xtext.xrobot.net.SocketInputBuffer

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class StateReceiver implements StateProvider<RobotServerState> {
	
	static val MAX_FAILURE_COUNT = 2000
	
	static val LOG = Logger.getLogger(StateReceiver)
	
	val SocketInputBuffer input

	val Selector selector
	
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
		try {
			while(!isStopped) {
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
							LOG.debug('Received state ' +  state.sampleTime)
						} catch(Exception exc) {
							failureCount++
							if (failureCount >= MAX_FAILURE_COUNT)
								throw exc
							LOG.error('State read failures ' + failureCount + " successes " + successCount)
						}
					}
				}
			}
		} catch(ClosedSelectorException e) {
			// Connection was closed softly -- ignore the exception
		} catch(Throwable t) {
			LOG.error('Error in state receiver', t)
		}
	}
	
	def start() {
		if (thread == null)
			throw new IllegalStateException('State receiver is already shut down.')
		thread.start
	}

	def isAlive() {
		if (thread == null)
			false
		else
			thread.alive
	}

	override getState() {
		if (!alive) {
			throw new SocketException('Connection to robot was closed.')
		}
		lastState
	}
	
	def shutdown() {
		isStopped = true
		ignoreExceptions[ thread.join(SOCKET_TIMEOUT) ]
		thread = null
	}
	
}