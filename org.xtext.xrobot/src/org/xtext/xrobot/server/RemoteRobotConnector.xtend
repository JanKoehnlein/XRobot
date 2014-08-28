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

@Singleton
class RemoteRobotConnector implements INetConfig {

	Map<String, RemoteRobot> name2robot = newHashMap
	
	private def connect(String robotName) {
		val ipAddress = robotName.getIPAddress
		if(ipAddress == null) {
			System.err.println('Brick \'' + robotName + '\' not located')			
			return null
		} 
		val socket = SocketChannel.open()
		socket.configureBlocking(false)
		if(!socket.connect(new InetSocketAddress(ipAddress, SERVER_PORT))) {
			val selector = Selector.open
			socket.register(selector, SelectionKey.OP_CONNECT)
			if(selector.select(SOCKET_TIMEOUT) == 0) {
				System.err.println('Timeout connecting to  \'' + robotName + '\'')
				return null
			}
			socket.finishConnect
		}
		try {
			val remoteRobot = new RemoteRobot(socket, 0)
			remoteRobot.waitForUpdate(SOCKET_TIMEOUT)
			System.err.println()
			System.err.println('Connected to ' + robotName + ' at ' + (socket.remoteAddress as InetSocketAddress).address)
			remoteRobot
		} catch(Exception exc) {
			socket?.close
			throw exc
		}
	}
	
	private def getIPAddress(String robotName) {
		val map=discover
		return map.get(robotName)
	}
	
	def getRobot(String name) {
		val connectedRobot = name2robot.get(name)
		if(connectedRobot != null) {
			if(connectedRobot.isAlive) {
				return connectedRobot
			} else {
				try {
					connectedRobot.release
				} catch(Exception exc) {
					// ignore
				}
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
	        while ((System.currentTimeMillis - start) < 2 * SOCKET_TIMEOUT) {
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