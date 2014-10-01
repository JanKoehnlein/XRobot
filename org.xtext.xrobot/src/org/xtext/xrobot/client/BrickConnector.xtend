package org.xtext.xrobot.client

import java.net.InetAddress
import java.net.InetSocketAddress
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.ServerSocketChannel
import java.nio.channels.SocketChannel
import lejos.hardware.BrickFinder
import org.apache.log4j.Logger
import org.xtext.xrobot.Robot
import org.xtext.xrobot.net.SocketInputBuffer

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*
import static org.xtext.xrobot.util.LEDPatterns.*
import static org.xtext.xrobot.util.SystemSounds.*
import org.xtext.xrobot.net.SocketOutputBuffer

class BrickConnector {
	
	static val LOG = Logger.getLogger(BrickConnector)

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
			val wifiAddress = InetAddress.getByName(robot.robotID.ipAddress)
			server.bind(new InetSocketAddress(wifiAddress, SERVER_PORT))
			serverSelector = Selector.open
			server.register(serverSelector, SelectionKey.OP_ACCEPT)
			robot.systemSound(ASCENDING_ARPEGGIO)
		} catch (Exception exc) {
			ignoreExceptions[serverSelector?.close]
			ignoreExceptions[server?.close]
			throw exc
		}
	}

	private def connect() {
		robot.led = ORANGE_BLINK
		isStopped = false
		while (!isStopped) {
			LOG.info('Accepting connections...')
			serverSelector.select(SOCKET_TIMEOUT)
			for (key : serverSelector.selectedKeys) {
				if (robot.escapePressed)
					isStopped = true
				else if (key.acceptable) {
					val socket = server.accept()
					if (socket != null) {
						socket.configureBlocking(false)
						LOG.info('Connected to ' + (socket.remoteAddress as InetSocketAddress).address)
						robot.led = GREEN
						robot.systemSound(BEEP)
						return socket
					}
				}
			}
			// Check whether we can reach the camera server in order to verify that we have
			// a working wifi connection
			if(!CAMERA_SERVER_ADDRESS.isReachable(20 * SOCKET_TIMEOUT)) {
				LOG.error('Network or camera server is down')
				robot.systemSound(LOW_BUZZ)
				isStopped = true
			}
		}
		robot.systemSound(DESCENDING_ARPEGGIO)
		LOG.info('Shutting down server...')
		ignoreExceptions[serverSelector?.close]
		ignoreExceptions[server?.close]
		LOG.info('...done.')
		return null
	}

	private def disconnect(Selector selector, SocketChannel socket) {
		robot.led = ORANGE_BLINK
		robot.systemSound(DOUBLE_BEEP)
		ignoreExceptions[selector?.close]		
		ignoreExceptions[socket?.close]
		robot.led = ORANGE
	}

	def run() {
		while (!isStopped) {
			var SocketChannel socket = null
			var Selector selector = null
			try {
				socket = connect
				if(socket != null) {
					robot.reset
					selector = Selector.open()
					run(socket, selector)
					disconnect(selector, socket)
				}
				robot.reset
			} catch (Exception exc) {
				LOG.error('Error: ' + exc.message)
				disconnect(selector, socket)
				robot.reset
				Thread.sleep(5000)
			}
		}
	}
	
	private def run(SocketChannel socket, Selector selector) {
		val input = new SocketInputBuffer(socket)
		val output = new SocketOutputBuffer(socket)
		socket.register(selector, SelectionKey.OP_READ + SelectionKey.OP_WRITE)
		val executor = new RobotExecutor(input, robot)
		val state = new RobotClientState
		var isRelease = false
		while (!isRelease) {
			selector.select(UPDATE_INTERVAL)
			if (robot.escapePressed) {
				return
			}
			for (key : selector.selectedKeys) {
				if (key.readable) {
					LOG.debug('Read message...')
					input.receive
					LOG.debug('...read ' + input.available + ' bytes.')
					while (input.available > 0 && !isRelease) {
						if (robot.escapePressed) {
							isRelease = true
						} else {
							isRelease = !executor.dispatchAndExecute
						}
					}
				}
				if (key.writable) {
					LOG.debug('Read state...')
					state.sample(robot)
					isRelease = robot.isDead
					state.write(output)
					output.send
				}
			}
			Thread.yield
		}
	}
}
