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
import static org.xtext.xrobot.util.IgnoreExceptionsExtenision.*

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
		try {
			server = ServerSocketChannel.open
			server.configureBlocking(false)
			server.bind(new InetSocketAddress(SERVER_PORT))
			serverSelector = Selector.open
			server.register(serverSelector, SelectionKey.OP_ACCEPT)
		} catch (Exception exc) {
			ignoreExceptions[serverSelector?.close]
			ignoreExceptions[server?.close]
			throw exc
		}
	}

	def connect() {
		robot.led = ORANGE_BLINK
		println('Accepting connections...')
		isStopped = false
		while (!isStopped) {
			serverSelector.select(SOCKET_TIMEOUT)
			for (key : serverSelector.selectedKeys) {
				if (robot.escapePressed)
					isStopped = true
				else if (key.acceptable) {
					val socket = server.accept()
					if (socket != null) {
						socket.configureBlocking(false)
						System.err.println()
						System.err.println('Connected to ' + (socket.remoteAddress as InetSocketAddress).address)
						robot.led = GREEN
						return socket
					}
				}
			}
		}
		System.err.println('Shutting down server...')
		ignoreExceptions[serverSelector?.close]
		ignoreExceptions[server?.close]
		System.err.println('...done.')
		return null
	}

	def disconnect(Selector selector, SocketChannel socket, StateSender stateSender) {
		robot.led = ORANGE_BLINK
		ignoreExceptions[selector?.close]		
		ignoreExceptions[socket?.close]
		stateSender?.shutdown
		robot.led = ORANGE
	}

	def run() {
		while (!isStopped) {
			var SocketChannel socket = null
			var StateSender stateSender = null
			var Selector selector = null
			try {
				socket = connect
				if(socket != null) {
					val input = new SocketInputBuffer(socket)
					selector = Selector.open()
					socket.register(selector, SelectionKey.OP_READ + SelectionKey.OP_WRITE)
					val executor = new RobotExecutor(input, robot)
					stateSender = new StateSender(robot, socket)
					stateSender.start
					var isRelease = false
					while (!isRelease && stateSender.alive) {
						selector.select(SOCKET_TIMEOUT)
						if (robot.escapePressed) {
							isRelease = true
						} else {
							for (key : selector.selectedKeys) {
								if (key.readable) {
									input.receive
									if (input.available > 0) {
										Thread.yield
										isRelease = !executor.dispatchAndExecute
									}
								}
							}
						}
					}
					disconnect(selector, socket, stateSender)
				}
				robot.stop
			} catch (Exception exc) {
				println('Error: ' + exc.message)
				disconnect(selector, socket, stateSender)
				robot.stop
				Thread.sleep(5000)
			}
		}
	}
}
