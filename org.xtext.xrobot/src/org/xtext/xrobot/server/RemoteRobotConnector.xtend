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
import org.apache.log4j.Logger
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

@Singleton
class RemoteRobotConnector implements IRemoteRobot.Connector {

	CameraClient cameraClient

	static val LOG = Logger.getLogger(RemoteRobotConnector)

	val Map<RobotID, RemoteRobotFactory> id2factory = newHashMap

	new() {
		this.cameraClient = new CameraClient()
		cameraClient.connect
	}

	private def connect(RobotID robotID) throws SocketTimeoutException {
		var SocketChannel socket = null
		try {
			val ipAddress = robotID.ipAddress
			if(ipAddress == null) 
				throw new SocketTimeoutException('Brick \'' + robotID + '\' not located')			
			socket = SocketChannel.open()
			socket.configureBlocking(false)
			if(!socket.connect(new InetSocketAddress(ipAddress, SERVER_PORT))) {
				val selector = Selector.open
				socket.register(selector, SelectionKey.OP_CONNECT)
				if(selector.select(4 * SOCKET_TIMEOUT) == 0) 
					throw new SocketTimeoutException('Timeout connecting to  \'' + robotID + '\'')
				socket.finishConnect
			}
			val remoteRobotFactory = new RemoteRobotFactory(robotID, socket, cameraClient)
			LOG.info('Connected to ' + robotID + ' at ' + (socket.remoteAddress as InetSocketAddress).address)
			remoteRobotFactory
		} catch(Exception exc) {
			socket?.close
			throw exc
		}
	}
	
	override getRobotFactory(RobotID robotID) {
		val connectedRobot = id2factory.get(robotID)
		if(connectedRobot != null) {
			if(connectedRobot.isAlive) {
				return connectedRobot
			} else {
				ignoreExceptions[connectedRobot.release]
			}
		}
		val newRobot = connect(robotID)
		id2factory.put(robotID, newRobot)
		return newRobot
	}
	
	public def discoverRobots() {	
		var DatagramSocket socket = null
		val result = newArrayList
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
		            try {
		            	val robotID = RobotID.valueOf(name)
		            	if(ipAddress != robotID.ipAddress)
		            		throw new IllegalArgumentException();
			            result.add(robotID)
		            } catch (IllegalArgumentException e) {
		            	LOG.error("Illegal robot name='" + name + "' ip='" + ipAddress + "' detected")
		            }
	        	} catch(SocketTimeoutException e) {
	        	}
	        }
		} finally {
			socket.close();
		}     
		return result
	}
}