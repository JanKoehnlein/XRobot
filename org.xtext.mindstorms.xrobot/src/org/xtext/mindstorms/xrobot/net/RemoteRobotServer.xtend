package org.xtext.mindstorms.xrobot.net

import java.net.ServerSocket
import java.net.SocketTimeoutException
import java.util.Map

class RemoteRobotServer extends Thread {

	Map<String, RemoteRobotProxy> name2robot = newHashMap
	
	boolean isStopped
	
	override void run() {
		isStopped = false
		val server = new ServerSocket(4444)
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
				val remoteRobotProxy = new RemoteRobotProxy(client)
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