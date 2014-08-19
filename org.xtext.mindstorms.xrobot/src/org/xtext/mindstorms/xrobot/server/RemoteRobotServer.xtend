package org.xtext.mindstorms.xrobot.server

import java.net.ServerSocket
import java.net.SocketTimeoutException
import java.util.Map
import com.google.inject.Singleton

@Singleton
class RemoteRobotServer extends Thread implements ServerConfig {

	Map<String, RemoteRobotProxy> name2robot = newHashMap
	
	boolean isStopped
	
	override void run() {
		isStopped = false
		val server = new ServerSocket(SERVER_PORT)
		server.soTimeout = 5000
		while(!isStopped) {
			try {
				val client = server.accept()
				println('Connected to ' + client.inetAddress)
				val name = client.inetAddress.toString
				try {
					name2robot.get(name)?.closeSocket
				} catch(Exception exc) {
					System.err.println('Error closing stale socket ' + name + ': ' + exc.message)
				}
				val remoteRobotProxy = new RemoteRobotProxy(client, 0)
				name2robot.put(remoteRobotProxy.name, remoteRobotProxy)
			} catch (SocketTimeoutException e) {
				// ignore
			}
		}
	}
	
	def shutdown() {
		isStopped = true
	}
	
	def getRobot(String name) {
		name2robot.get(name)
	}
	
	def getRobotNames() {
		name2robot.keySet.filter[robot.isAlive]
	}
}