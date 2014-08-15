package org.xtext.mindstorms.xrobot.tests

import lejos.hardware.BrickFinder

class LEDTest {
	def static void main(String[] args) {
		val brick = BrickFinder.getDefault
		val led = brick.LED
		for(i: 0..20) {
			println("LED pattern " + i)
			led.pattern = i
			Thread.sleep(1000)		
		}
	}
	
}