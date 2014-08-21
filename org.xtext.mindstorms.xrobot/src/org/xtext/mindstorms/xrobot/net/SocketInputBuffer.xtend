package org.xtext.mindstorms.xrobot.net

import java.nio.ByteBuffer
import java.nio.channels.SocketChannel
import java.nio.charset.Charset
import java.nio.channels.Selector
import java.nio.channels.SelectionKey
import java.net.SocketTimeoutException

class SocketInputBuffer {
	
	ByteBuffer buffer = ByteBuffer.allocate(2048)
	
	SocketChannel socketChannel
	
	Selector selector
	
	new(SocketChannel socketChannel) {
		this.socketChannel = socketChannel
		selector = Selector.open
		socketChannel.register(selector, SelectionKey.OP_READ)	
	}
	
	def receive() {
		buffer.rewind
		socketChannel.read(buffer)
		buffer.rewind
	}

	def receiveBlocking() {
		selector.select(1000)
		for(key: selector.selectedKeys) {
			if(key.readable) {
				receive
				return				
			}
		}
		throw new SocketTimeoutException()
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
}