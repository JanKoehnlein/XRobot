package org.xtext.mindstorms.xrobot

import lejos.hardware.BrickFinder
import lejos.hardware.Button
import org.xtext.mindstorms.xrobot.util.SoundUtil

class XRobot {
	
	extension SoundUtil soundUtil = new SoundUtil
	
	def static void main(String[] args) {
		new XRobot().run
	}
	
	def run() {
		val brick = BrickFinder.getDefault
		brick.audio.playSample('samples/futile.wav', 100)
		val robot = new Robot(brick)
		for(i: 1..4) {
			robot.rotate(90)
			robot.forward(100)
			println(robot.position)			
		}
		Button.waitForAnyPress
	}
	
}