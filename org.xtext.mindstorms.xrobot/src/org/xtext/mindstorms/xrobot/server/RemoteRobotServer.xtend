package org.xtext.mindstorms.xrobot.server

import com.google.inject.Singleton
import java.net.InetSocketAddress
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.ServerSocketChannel
import java.util.Map
import org.xtext.mindstorms.xrobot.net.INetConfig

@Singleton
class RemoteRobotServer extends Thread implements INetConfig {

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
			selector.select(SOCKET_TIMEOUT)
			for(key: selector.selectedKeys) {
				if(key.acceptable) {
					val client = server.accept()
					if(client != null) {
						client.configureBlocking(false)
						val remoteRobotProxy = new RemoteRobotProxy(client, 0)
						val stateReceiver = new StateReceiver(remoteRobotProxy, client)
						stateReceiver.start
						while(remoteRobotProxy.state == null) 
							Thread.sleep(20)
						val robotName = remoteRobotProxy.name
						val staleClientData = name2robot.put(robotName, remoteRobotProxy)
						System.err.println()
						System.err.println('Connected to ' + robotName + ' at ' + (client.remoteAddress as InetSocketAddress).address)
						staleClientData?.closeSocket
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