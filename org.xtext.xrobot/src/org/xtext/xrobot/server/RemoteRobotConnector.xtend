package org.xtext.xrobot.server

import com.google.inject.Singleton
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetSocketAddress
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.SocketChannel
import java.util.Map
import org.xtext.xrobot.net.INetConfig
import java.net.SocketTimeoutException

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
		val remoteRobot = new RemoteRobot(socket, 0)
		val stateReceiver = new StateReceiver(remoteRobot, socket)
		stateReceiver.start
		while(remoteRobot.state == null) 
			Thread.sleep(20)
		val staleClientData = name2robot.put(robotName, remoteRobot)
		System.err.println()
		System.err.println('Connected to ' + robotName + ' at ' + (socket.remoteAddress as InetSocketAddress).address)
		staleClientData?.closeSocket
		remoteRobot
	}
	
	private def getIPAddress(String robotName) {
		val map=discover
		return map.get(robotName)
	}
	
	def getRobot(String name) {
		val connectedRobot = name2robot.get(name)
		if(connectedRobot != null) {
			return connectedRobot
		} else {
			val newRobot = connect(name)
			if(newRobot != null) {
				name2robot.put(name, newRobot)
				return newRobot		
			}
		}
		return null
	}
	
	def getRobotNames() {
		discover.keySet
	}
	
	private def discover() {	
		var DatagramSocket socket = null
		val result = newHashMap
		try {
			socket = new DatagramSocket(DISCOVERY_PORT)
			socket.setSoTimeout(2 * SOCKET_TIMEOUT);
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