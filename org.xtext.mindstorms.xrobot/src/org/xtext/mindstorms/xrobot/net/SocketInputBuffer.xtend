package org.xtext.mindstorms.xrobot.net

import java.nio.ByteBuffer
import java.nio.channels.SocketChannel
import java.nio.charset.Charset

class SocketInputBuffer {
	
	ByteBuffer buffer = ByteBuffer.allocate(2048)
	
	SocketChannel socketChannel
	
	new(SocketChannel socketChannel) {
		this.socketChannel = socketChannel
	}
	
	def receive() {
		buffer.rewind
		buffer.limit = 2048
		socketChannel.read(buffer)
		buffer.limit = buffer.position
		buffer.rewind
	}

	def readBoolean() {
		val b = buffer.get as int
		switch b {
			case 1: true
			case 0: false
			default: throw new RuntimeException('Invalid boolean value ' + b)
		}
	}
	
	def readInt() {
		buffer.int
	}
	
	def readLong() {
		buffer.long
	}
	
	def readFloat() {
		buffer.float
	}
	
	def readDouble() {
		buffer.double
	}
	
	def readString() {
		val length = buffer.int
		val b = newByteArrayOfSize(length)
		buffer.get(b)
		new String(b, Charset.forName('UTF-8'))
	}
	
	def hasMore() {
		buffer.position < buffer.limit
	}
}