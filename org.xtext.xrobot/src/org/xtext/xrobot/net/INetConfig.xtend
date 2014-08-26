package org.xtext.xrobot.net

interface INetConfig {
	static val DISCOVERY_PORT = 3016
	static val DISCOVERY_PACKET_SIZE = 32
	
	static val SERVER_PORT = 4444
	
	static val SOCKET_TIMEOUT = 1000
	
	static val BUFFER_SIZE = 32768
	static val UPDATE_INTERVAL = 30 
}