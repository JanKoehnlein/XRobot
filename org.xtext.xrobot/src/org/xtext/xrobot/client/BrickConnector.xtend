package org.xtext.xrobot.client

import java.net.InetSocketAddress
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.net.SocketInputBuffer

import static org.xtext.xrobot.util.LEDPatterns.*

class BrickConnector implements INetConfig {
	
	SocketChannel socket
	
	Robot robot
	
	SocketInputBuffer input
	
	StateSender stateSender
	
	def static void main(String[] args) {
		new BrickConnector(new Robot(BrickFinder.getLocal)).run
	}
	
	new(Robot robot) {
		this.robot = robot
		robot.led = ORANGE
	}
	
	def connect() {
		println('Connecting to server...')
		robot.led = ORANGE_BLINK
		socket = SocketChannel.open()
		socket.configureBlocking(false)
		if(!socket.connect(new InetSocketAddress(SERVER_ADDRESS, SERVER_PORT))) {
			val selector = Selector.open
			socket.register(selector, SelectionKey.OP_CONNECT)
			while (selector.select(SOCKET_TIMEOUT) == 0) {}
			socket.finishConnect
		}
		input = new SocketInputBuffer(socket)
		println('...connected!')
		robot.led =  GREEN
	}
	
	def disconnect() {
		try {
			robot.led = ORANGE_BLINK
			socket.close
		} finally {
			robot.led = ORANGE
		}
	}	
	
	def run() {
		var isStopped = false
		while(!isStopped) {
			try {
				if(robot.escapePressed)
					return;
				connect
				val selector = Selector.open()
				socket.register(selector, SelectionKey.OP_READ + SelectionKey.OP_WRITE)
				val executor = new RobotExecutor(input, robot)
				stateSender = new StateSender(robot, socket)
				stateSender.start
				while(!isStopped && stateSender.alive) {
					selector.select(SOCKET_TIMEOUT)
					if(robot.escapePressed) {
						isStopped = true
					} else {
						for(key: selector.selectedKeys) {
							if(key.readable) {
								input.receive
								if(input.hasMore) {
									Thread.yield									
									isStopped = !executor.dispatchAndExecute
								}
							}
						}
					}
				}
				stateSender.shutdown
				disconnect
			} catch(Exception exc) {
				println('Error: ' + exc.message)
				stateSender?.shutdown
				robot.stop
				try {
					disconnect
				} catch(Exception e) {}
				Thread.sleep(5000)
			}
		}
	}
}