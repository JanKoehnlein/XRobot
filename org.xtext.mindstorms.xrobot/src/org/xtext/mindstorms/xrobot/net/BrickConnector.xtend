package org.xtext.mindstorms.xrobot.net

import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Socket
import lejos.hardware.BrickFinder
import org.xtext.mindstorms.xrobot.Robot

import static org.xtext.mindstorms.xrobot.util.LEDPatterns.*

class BrickConnector {
	
	Socket socket
	
	Robot robot
	
	DataInputStream input
	
	DataOutputStream output
	
	def static void main(String[] args) {
		new BrickConnector(new Robot(BrickFinder.getLocal)).run
	}
	
	new(Robot robot) {
		this.robot = robot
		robot.led = ORANGE
	}
	
	def connect() {
		println('Connecting to server...')
		robot.led = ORANGE_BLINK
		socket = new Socket()
		socket.connect(new InetSocketAddress('10.0.1.10', 4444), 5000)
		input = new DataInputStream(socket.inputStream)
		output = new DataOutputStream(socket.outputStream)
		println('...connected!')
		robot.led =  GREEN
	}
	
	def disconnect() {
		try {
			robot.led = ORANGE_BLINK
			socket.close
		} finally {
			robot.led = ORANGE
		}
	}	
	
	def run() {
		var isStopped = false
		while(!isStopped) {
			try {
				if(robot.escapePressed)
					return;
				connect
				val executor = new BrickExecutor(input, output, robot)
				while(!isStopped) {
					isStopped = !executor.executeNext
				}
				disconnect
			} catch(IOException exc) {
				println('Error: ' + exc.message)
				try {
					disconnect
				} catch(Exception e) {}
				Thread.sleep(5000)
			}
		}
	}
}