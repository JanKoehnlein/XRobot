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

	private def disconnect(SocketChannel socket, Selector readSelector, Selector writeSelector) {
		robot.led = ORANGE_BLINK
		robot.systemSound(DOUBLE_BEEP)
		ignoreExceptions[readSelector?.close]
		ignoreExceptions[writeSelector?.close]		
		ignoreExceptions[socket?.close]
		robot.led = ORANGE
	}

	def run() {
		while (!isStopped) {
			var SocketChannel socket = null
			var Selector readSelector = null
			var Selector writeSelector = null
			try {
				socket = connect
				if(socket != null) {
					robot.reset
					readSelector = Selector.open()
					writeSelector = Selector.open()
					run(socket, readSelector, writeSelector)
					disconnect(socket, readSelector, writeSelector)
				}
				robot.reset
			} catch (Exception exc) {
				LOG.error('Error: ' + exc.message)
				disconnect(socket, readSelector, writeSelector)
				robot.reset
				Thread.sleep(5000)
			}
		}
	}
	
	private def run(SocketChannel socket, Selector readSelector, Selector writeSelector) {
		val input = new SocketInputBuffer(socket)
		val output = new SocketOutputBuffer(socket)
		socket.register(readSelector, SelectionKey.OP_READ)
		socket.register(writeSelector, SelectionKey.OP_WRITE)
		val executor = new RobotExecutor(input, robot)
		val state = new RobotClientState
		var isRelease = false
		var isDead = false
		while (!isRelease && !robot.escapePressed) {
			
			// Sample the robot state and send it to the server
			writeSelector.select(UPDATE_INTERVAL)
			for (key : writeSelector.selectedKeys) {
				if (key.writable) {
//					LOG.debug('Send state...')
					state.sample(robot)
					if (state.dead) {
						isDead = true
						LOG.debug('Dead robot detected')
					} else if (isDead) {
						// Manipulate the robot state so the server receives the dead flag
						state.dead = true 
					}
					state.write(output)
					output.send
				}
			}
			if (robot.escapePressed) {
				return
			}
			
			// Execute a command received from the server
			if (input.available > 0) {
				isRelease = !executor.dispatchAndExecute(!isDead)
			} else {
				readSelector.select(UPDATE_INTERVAL)
				for (key : readSelector.selectedKeys) {
					if (key.readable) {
//						LOG.debug('Read message...')
						input.receive
//						LOG.debug('...read ' + input.available + ' bytes.')
						if (input.available > 0) {
							isRelease = !executor.dispatchAndExecute(!isDead)
						}
					}
				}
			}
			
			// Give some scheduling time to the Lejos threads
			Thread.yield
		}
	}
}
