package org.xtext.mindstorms.xrobot.server

import com.google.inject.Singleton
import java.net.InetSocketAddress
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.ServerSocketChannel
import java.util.Map

@Singleton
class RemoteRobotServer extends Thread implements IServerConfig {

	Map<String, RemoteRobotProxy> name2robot = newHashMap
	
	volatile boolean isStopped
	
	override void run() {
		isStopped = false
		val server = ServerSocketChannel.open
		server.configureBlocking(false)
		server.bind(new InetSocketAddress(SERVER_PORT))
		val selector = Selector.open
		server.register(selector, SelectionKey.OP_ACCEPT)
		while(!isStopped) {
			selector.select(2000)
			for(key: selector.selectedKeys) {
				if(key.acceptable) {
					val client = server.accept()
					if(client != null) {
						client.configureBlocking(false)
						println('Connected to ' + client.remoteAddress)
						val remoteRobotProxy = new RemoteRobotProxy(client, 0)
						val staleClient = name2robot.put(remoteRobotProxy.name, remoteRobotProxy)
						staleClient?.closeSocket
					}
				} 
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
		name2robot.keySet
	}
}