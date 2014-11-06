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
import org.xtext.xrobot.net.SocketOutputBuffer

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*
import static org.xtext.xrobot.util.LEDPatterns.*
import static org.xtext.xrobot.util.SystemSounds.*

/**
 * The main class of the client application running on the Lego brick.
 */
class BrickConnector {
	
	static val LOG = Logger.getLogger(BrickConnector)

	ServerSocketChannel server
	Selector serverSelector

	Robot robot

	boolean isStopped = false

	/**
	 * Entry method of the application.
	 */
	def static void main(String[] args) {
		new BrickConnector(new Robot(BrickFinder.getLocal)).run
	}

	/**
	 * Initialize the brick connector.
	 */
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

	/**
	 * Connect to the server via a socket channel.
	 */
	private def connect() {
		robot.led = ORANGE_BLINK
		isStopped = false
		while (!isStopped) {
			LOG.debug('Accepting connections...')
			serverSelector.select(SOCKET_TIMEOUT)
			if (robot.escapePressed)
				isStopped = true
			else {
				for (key : serverSelector.selectedKeys) {
					if (key.acceptable) {
						val socket = server.accept()
						if (socket != null) {
							socket.configureBlocking(false)
							LOG.debug('Connected to ' + (socket.remoteAddress as InetSocketAddress).address)
							robot.led = GREEN
							robot.systemSound(BEEP)
							return socket
						}
					}
				}
			}
		}
		robot.systemSound(DESCENDING_ARPEGGIO)
		LOG.debug('Shutting down server...')
		ignoreExceptions[serverSelector?.close]
		ignoreExceptions[server?.close]
		LOG.debug('...done.')
		return null
	}

	/**
	 * Disconnect from the server.
	 */
	private def disconnect(SocketChannel socket, Selector readSelector, Selector writeSelector) {
		robot.led = ORANGE_BLINK
		robot.systemSound(DOUBLE_BEEP)
		ignoreExceptions[readSelector?.close]
		ignoreExceptions[writeSelector?.close]		
		ignoreExceptions[socket?.close]
		robot.led = ORANGE
	}

	/**
	 * Main loop of the application, runs until it is stopped.
	 */
	def run() {
		while (!isStopped) {
			var SocketChannel socket = null
			var Selector readSelector = null
			var Selector writeSelector = null
			try {
				socket = connect
				if (robot.escapePressed) {
					isStopped = true
				} else if (socket != null) {
					robot.reset
					readSelector = Selector.open()
					writeSelector = Selector.open()
					run(socket, readSelector, writeSelector)
					disconnect(socket, readSelector, writeSelector)
				}
				robot.reset
			} catch (Exception exc) {
				LOG.error('Error: ' + exc.message, exc)
				disconnect(socket, readSelector, writeSelector)
				robot.reset
				Thread.sleep(5000)
			}
		}
	}
	
	/** Definition of states of the connector application. */
	private enum ConnectorState { SEND, RECEIVE }
	
	/**
	 * Run the actual application with a successful connection to the server.
	 */
	private def run(SocketChannel socket, Selector readSelector, Selector writeSelector) {
		val input = new SocketInputBuffer(socket)
		val output = new SocketOutputBuffer(socket)
		socket.register(readSelector, SelectionKey.OP_READ)
		socket.register(writeSelector, SelectionKey.OP_WRITE)
		val executor = new RobotExecutor(input, robot)
		val clientState = new RobotClientState
		var isRelease = false
		var connectorState = ConnectorState.SEND
		do {
			switch (connectorState) {
				
				case SEND: {
					// Sample the robot state and send it to the server
					writeSelector.select(UPDATE_INTERVAL)
					for (key : writeSelector.selectedKeys) {
						if (key.writable) {
							clientState.sample(robot)
							clientState.write(output)
							output.send
						}
					}
					connectorState = ConnectorState.RECEIVE
				}
				
				case RECEIVE: {
					// Execute a command received from the server
					if (input.available > 0) {
						isRelease = !executor.dispatchAndExecute(!clientState.dead)
					} else {
						readSelector.select(UPDATE_INTERVAL)
						for (key : readSelector.selectedKeys) {
							if (key.readable) {
								input.receive
								if (input.available > 0) {
									isRelease = !executor.dispatchAndExecute(!clientState.dead)
								}
							}
						}
					}
					connectorState = ConnectorState.SEND
				}
				
			}
			if (robot.escapePressed) {
				isRelease = true
			}
			// Give some scheduling time to the Lejos threads
			Thread.yield
		} while (!isRelease)
		
		// Send a last state update to the server in order to acknowledge the release command
		writeSelector.select(SOCKET_TIMEOUT)
		for (key : writeSelector.selectedKeys) {
			if (key.writable) {
				clientState.sample(robot)
				clientState.write(output)
				output.send
			}
		}
	}
}
