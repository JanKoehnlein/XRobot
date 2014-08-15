package org.xtext.mindstorms.xrobot.tests

import lejos.hardware.BrickFinder
import lejos.hardware.motor.NXTRegulatedMotor

class RemoteSteeringTest {
	def static void main(String[] args) {
		val brick = BrickFinder.getDefault
		val motor = new NXTRegulatedMotor(brick.getPort('B'))
		motor.speed = motor.maxSpeed
		motor.rotate(90)
	}
	
}