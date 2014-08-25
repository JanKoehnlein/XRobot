package org.xtext.mindstorms.xrobot.server

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.xtext.mindstorms.xrobot.net.INetConfig
import org.xtext.mindstorms.xrobot.net.SocketInputBuffer

class StateReceiver extends Thread implements INetConfig {
	
	RemoteRobotProxy robot	
	SocketInputBuffer input

	Selector selector
	
	volatile boolean isStopped = false
	
	new(RemoteRobotProxy robot, SocketChannel socket) {
		this.robot = robot
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
						while(input.hasMore)
							state.read(input)
						robot.state = state
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
	
	def shutdown() {
		isStopped = true
	}
}