package org.xtext.xrobot.server

import com.google.inject.Singleton
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetSocketAddress
import java.net.SocketTimeoutException
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import java.util.Map
import org.xtext.xrobot.net.INetConfig
import org.apache.log4j.Logger
import static org.xtext.xrobot.util.IgnoreExceptionsExtenision.*
import org.xtext.xrobot.RobotID

@Singleton
class RemoteRobotConnector implements INetConfig {

	static val LOG = Logger.getLogger(RemoteRobotConnector)

	val Map<String, RemoteRobotFactory> name2robot = newHashMap

	private def connect(String robotName) throws SocketTimeoutException {
		var SocketChannel socket = null
		try {
			val ipAddress = RobotID.valueOf(robotName).ipAddress
			if(ipAddress == null) 
				throw new SocketTimeoutException('Brick \'' + robotName + '\' not located')			
			socket = SocketChannel.open()
			socket.configureBlocking(false)
			if(!socket.connect(new InetSocketAddress(ipAddress, SERVER_PORT))) {
				val selector = Selector.open
				socket.register(selector, SelectionKey.OP_CONNECT)
				if(selector.select(4 * SOCKET_TIMEOUT) == 0) 
					throw new SocketTimeoutException('Timeout connecting to  \'' + robotName + '\'')
				socket.finishConnect
			}
			val remoteRobotFactory = new RemoteRobotFactory(robotName, socket)
			LOG.info('Connected to ' + robotName + ' at ' + (socket.remoteAddress as InetSocketAddress).address)
			remoteRobotFactory
		} catch(Exception exc) {
			socket?.close
			throw exc
		}
	}
	
	def getRobotFactory(String name) {
		val connectedRobot = name2robot.get(name)
		if(connectedRobot != null) {
			if(connectedRobot.isAlive) {
				return connectedRobot
			} else {
				ignoreExceptions[connectedRobot.release]
			}
		}
		val newRobot = connect(name)
		name2robot.put(name, newRobot)
		return newRobot
	}
	
	def getRobotNames() {
		discover.keySet
	}
	
	private def discover() {	
		var DatagramSocket socket = null
		val result = newHashMap
		try {
			socket = new DatagramSocket(DISCOVERY_PORT)
			socket.setSoTimeout(4 * SOCKET_TIMEOUT);
	        val packet = new DatagramPacket (newByteArrayOfSize(DISCOVERY_PACKET_SIZE), DISCOVERY_PACKET_SIZE)
	        val start = System.currentTimeMillis
	        while ((System.currentTimeMillis - start) < 4 * SOCKET_TIMEOUT) {
	        	try {
		            socket.receive(packet)
		            val name = new String(packet.data, "UTF-8").trim
		            val ipAddress = packet.address.hostAddress
		            result.put(name, ipAddress)
	        	} catch(SocketTimeoutException e) {
	        	}
	        }
		} finally {
			socket.close();
		}     
		return result
	}
}