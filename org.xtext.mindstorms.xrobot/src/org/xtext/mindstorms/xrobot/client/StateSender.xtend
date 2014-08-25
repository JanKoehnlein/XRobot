package org.xtext.mindstorms.xrobot.client

import org.xtext.mindstorms.xrobot.Robot
import org.xtext.mindstorms.xrobot.net.SocketOutputBuffer
import java.nio.channels.SocketChannel
import java.nio.channels.Selector
import java.nio.channels.SelectionKey
import java.nio.channels.ClosedSelectorException
import org.xtext.mindstorms.xrobot.net.INetConfig

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