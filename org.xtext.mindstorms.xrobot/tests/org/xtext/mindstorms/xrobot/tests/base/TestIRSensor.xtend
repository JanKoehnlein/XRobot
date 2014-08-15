package org.xtext.mindstorms.xrobot.tests.base

import lejos.hardware.BrickFinder
import lejos.hardware.sensor.EV3IRSensor

class TestIRSensor {
	def static void main(String[] args) {
		val brick = BrickFinder.getDefault
		val irSensor = new EV3IRSensor(brick.getPort('S4'))
		val sample = newFloatArrayOfSize(8)
		while(!brick.getKey('Escape').down) {
			irSensor.seekMode.fetchSample(sample, 0)
			println(sample.get(2) + ' ' + sample.get(3))
			Thread.sleep(800)
		}
	}
}