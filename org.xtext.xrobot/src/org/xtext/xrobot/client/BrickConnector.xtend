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
import java.nio.channels.ServerSocketChannel

class BrickConnector implements INetConfig {
	
	ServerSocketChannel server
	Selector serverSelector

	Robot robot
	
	boolean isStopped = false
	
	def static void main(String[] args) {
		new BrickConnector(new Robot(BrickFinder.getLocal)).run
	}
	
	new(Robot robot) {
		this.robot = robot
		robot.led = ORANGE
		server = ServerSocketChannel.open
		server.configureBlocking(false)
		server.bind(new InetSocketAddress(SERVER_PORT))
		serverSelector = Selector.open
		server.register(serverSelector, SelectionKey.OP_ACCEPT)
	}
	
	def connect() {
		robot.led = ORANGE_BLINK
		println('Accepting connections...')
		isStopped = false
		while(!isStopped) {
			serverSelector.select(SOCKET_TIMEOUT)
			for(key: serverSelector.selectedKeys) {
				if(robot.escapePressed) 
					isStopped = true
				else if(key.acceptable) {
					val socket = server.accept()
					if(socket != null) {
						socket.configureBlocking(false)
						System.err.println()
						System.err.println('Connected to ' + (socket.remoteAddress as InetSocketAddress).address)
						robot.led =  GREEN
						return socket
					}
				} 
			}
		}
		System.err.println('Shutting down server...')
		try {
			server?.close
		} finally {
			System.err.println('...done.')
		}
		return null
	}
	
	def disconnect(SocketChannel socket) {
		try {
			robot.led = ORANGE_BLINK
			socket?.close
		} finally {
			robot.led = ORANGE
		}
	}	
	
	def run() {
		var isDisconnect = false
		while(!isDisconnect) {
			var SocketChannel socket = null
			var StateSender stateSender = null
			try {
				if(robot.escapePressed)
					return;
				socket = connect
				val input = new SocketInputBuffer(socket)
				val selector = Selector.open()
				socket.register(selector, SelectionKey.OP_READ + SelectionKey.OP_WRITE)
				val executor = new RobotExecutor(input, robot)
				stateSender = new StateSender(robot, socket)
				stateSender.start
				while(!isDisconnect && stateSender.alive) {
					selector.select(SOCKET_TIMEOUT)
					if(robot.escapePressed) {
						isDisconnect = true
					} else {
						for(key: selector.selectedKeys) {
							if(key.readable) {
								input.receive
								if(input.hasMore) {
									Thread.yield									
									isDisconnect = !executor.dispatchAndExecute
								}
							}
						}
					}
				}
				stateSender.shutdown
				socket.disconnect
			} catch(Exception exc) {
				println('Error: ' + exc.message)
				stateSender?.shutdown
				robot.stop
				try {
					socket.disconnect
				} catch(Exception e) {}
				Thread.sleep(5000)
			}
		}
	}
}