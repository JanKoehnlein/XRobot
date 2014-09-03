package org.xtext.xrobot.net

import java.nio.ByteBuffer
import java.nio.channels.SocketChannel
import java.nio.charset.Charset
import java.nio.BufferOverflowException

class SocketInputBuffer implements INetConfig {
	
	ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE)
	
	SocketChannel socketChannel
	
	new(SocketChannel socketChannel) {
		this.socketChannel = socketChannel
	}
	
	def receive() {
		buffer.rewind
		buffer.limit = BUFFER_SIZE
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
		if(length + buffer.position > buffer.limit) 
			throw new BufferOverflowException
		val b = newByteArrayOfSize(length)
		buffer.get(b)
		new String(b, Charset.forName('UTF-8'))
	}
	
	def available() {
//		println('Recevied ' + (buffer.limit-buffer.position) + ' bytes')
		buffer.limit - buffer.position
	}
}