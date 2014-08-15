package org.xtext.mindstorms.xrobot.net

import java.io.DataInputStream
import java.io.DataOutputStream
import java.net.Socket
import org.xtext.mindstorms.xrobot.IRobot
import org.xtext.mindstorms.xrobot.data.SensorSample

class RemoteRobotProxy implements IRobot {
	
	Socket socket
	
	DataInputStream input
	
	DataOutputStream output
	
	new(Socket clientSocket) {
		this(new DataInputStream(clientSocket.inputStream), 
			new DataOutputStream(clientSocket.outputStream))
	}
	
	new(DataInputStream input, DataOutputStream output) {
		this.input = input
		this.output = output
	}
	
	override forward(double distance) {
		output.writeInt(0)
		output.writeDouble(distance)
		output.flush
		input.readBoolean
	}
	
	override backward(double distance) {
		output.writeInt(1)
		output.writeDouble(distance)
		output.flush
		input.readBoolean
	}
	
	override setTravelSpeed(double speed) {
		output.writeInt(2)
		output.writeDouble(speed)
		output.flush
		input.readBoolean
	}
	
	override getTravelSpeed() {
		output.writeInt(3)
		output.flush
		input.readDouble
	}
	
	override getMaxTravelSpeed() {
		output.writeInt(4)
		output.flush
		input.readDouble
	}
	
	override rotate(double angle) {
		output.writeInt(5)
		output.writeDouble(angle)
		output.flush
		input.readBoolean
	}
	
	override setRotateSpeed(double speed) {
		output.writeInt(6)
		output.writeDouble(speed)
		output.flush
		input.readBoolean
	}
	
	override getRotateSpeed() {
		output.writeInt(7)
		output.flush
		input.readDouble
	}
	
	override getRotateMaxSpeed() {
		output.writeInt(8)
		output.flush
		input.readDouble
	}
	
	override curveForward(double radius, double angle) {
		output.writeInt(9)
		output.writeDouble(radius)
		output.writeDouble(angle)
		output.flush
		input.readBoolean
	}
	
	override curveBackward(double radius, double angle) {
		output.writeInt(10)
		output.writeDouble(radius)
		output.writeDouble(angle)
		output.flush
		input.readBoolean
	}
	
	override curveTo(double angle, double distance) {
		output.writeInt(11)
		output.writeDouble(angle)
		output.writeDouble(distance)
		output.flush
		input.readBoolean
	}
	
	override stop() {
		output.writeInt(12)
		output.flush
		input.readBoolean
	}
	
	override escapePressed() {
		output.writeInt(17)
		output.flush
		input.readBoolean
	}
	
	override fireWeapon() {
		output.writeInt(18)
		output.flush
		input.readBoolean
	}
	
	override getName() {
		output.writeInt(19)
		output.flush
		input.readUTF
	}
	
	override sample() {
		output.writeInt(20) 
		output.flush
		new SensorSample(input.readLong, 
			input.readDouble, input.readDouble, 
			input.readDouble, input.readDouble, input.readDouble)
	}

	def shutdown() {
		output.writeInt(-1)
		output.flush
		input.readBoolean
		closeSocket
	}
	
	def isAlive() {
		if(socket != null && socket.closed)
			return false
		output.writeInt(-2)
		output.flush
		input.readBoolean
	}

	def closeSocket() {
		socket?.close
	}
}
