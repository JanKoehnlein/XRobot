package org.xtext.xrobot.client

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.xtext.xrobot.Robot
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.net.SocketOutputBuffer

class StateSender extends Thread implements INetConfig {
	
	Robot robot	
	SocketOutputBuffer output

	RobotClientState state
	Selector selector
	
	volatile boolean isStopped = false
	
	new(Robot robot, SocketChannel socket) {
		this.robot = robot
		this.output = new SocketOutputBuffer(socket)
		this.selector = Selector.open
		socket.register(selector, SelectionKey.OP_WRITE)	
		this.state = new RobotClientState
		daemon = true
	}

	override run() {
		while(!isStopped) {
			try {
				state.sample(robot)
				selector.select
				for(key: selector.selectedKeys) {
					if(key.isWritable) {
						state.write(output)
						output.send
					}
				}
				Thread.sleep(UPDATE_INTERVAL)						
			} catch(ClosedSelectorException e) {
				return
			} catch(Exception e) {
				e.printStackTrace
				return
			}
		}
	}
	
	def void shutdown() {
		isStopped = true
	}
}