/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.net

import java.io.IOException
import java.nio.ByteBuffer
import java.nio.channels.SocketChannel
import java.nio.charset.Charset

import static org.xtext.xrobot.net.INetConfig.*

class SocketOutputBuffer {
		
	val ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE)
	
	val SocketChannel channel
	
	new(SocketChannel channel) {
		this.channel = channel
	}
	
	def send() throws IOException {
		buffer.limit = buffer.position
		buffer.rewind
		channel.write(buffer)
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