package org.xtext.xrobot.net

import java.nio.ByteBuffer
import java.nio.channels.SocketChannel
import java.nio.charset.Charset

import static org.xtext.xrobot.net.INetConfig.*

class SocketOutputBuffer {
		
//	static val LOG = Logger.getLogger(SocketOutputBuffer)
	
	val ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE)
	
	val SocketChannel channel
	
	new(SocketChannel channel) {
		this.channel = channel
	}
	
	def send() {
		buffer.limit = buffer.position
		buffer.rewind
		channel.write(buffer)
//		LOG.debug('...sent ' + buffer.limit + ' bytes.')
		buffer.rewind
		buffer.limit = BUFFER_SIZE
	}
	
	def writeBoolean(boolean b) {
		buffer.put((if (b) 1 else 0) as byte)
	}
	
	def writeInt(int i) {
		buffer.putInt(i)
	}
	
	def writeLong(long l) {
		buffer.putLong(l)
	}
	
	def writeFloat(float f) {
		buffer.putFloat(f)
	}
	
	def writeDouble(double d) {
		buffer.putDouble(d)
	}
	
	def writeString(String s) {
		val bytes = s.getBytes(Charset.forName('UTF-8'))
		buffer.putInt(bytes.length)
		buffer.put(bytes)
	}
}