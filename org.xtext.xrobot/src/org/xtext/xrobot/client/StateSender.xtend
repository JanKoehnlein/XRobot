package org.xtext.xrobot.client

import java.nio.channels.ClosedSelectorException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import org.apache.log4j.Logger
import org.xtext.xrobot.Robot
import org.xtext.xrobot.net.SocketOutputBuffer

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class StateSender extends Thread {
	
	static val LOG = Logger.getLogger(StateSender)
	
	Robot robot	
	SocketOutputBuffer output

	RobotClientState state
	Selector selector
	
	volatile boolean isStopped = false
	
	new(Robot robot, SocketChannel socket) throws Exception {
		this.name = 'StateSender'
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
				synchronized(robot) {
					state.sample(robot)
				}
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
				LOG.error(e.message)
				ignoreExceptions[selector?.close]
				return
			}
		}
	}
	
	def void shutdown() {
		isStopped = true
	}
}