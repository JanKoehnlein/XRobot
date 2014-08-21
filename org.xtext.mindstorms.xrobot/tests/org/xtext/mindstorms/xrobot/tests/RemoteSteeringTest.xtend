package org.xtext.mindstorms.xrobot.tests

import lejos.hardware.BrickFinder
import lejos.hardware.sensor.EV3ColorSensor

class RemoteSteeringTest {
	def static void main(String[] args) {
		val brick = BrickFinder.getDefault
		val sensor = new EV3ColorSensor(brick.getPort('S3'))
		val sample = newFloatArrayOfSize(1)
		var duration = 0l
		for(i:1..100) {
			val start = System.currentTimeMillis
			sensor.redMode.fetchSample(sample, 0)
			duration += (System.currentTimeMillis - start)
			println(duration)
		}
		println(sample.get(0))		
		sensor.close
//		val motor = new NXTRegulatedMotor(brick.getPort('B'))
//		motor.speed = motor.maxSpeed
//		motor.rotate(90)
	}
	
}