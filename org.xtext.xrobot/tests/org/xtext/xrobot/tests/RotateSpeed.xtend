package org.xtext.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot

class RotateSpeed {
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		while (!robot.escapePressed) {
			robot.rotateSpeed = 1
			robot.rotate(10)	
			robot.rotateSpeed = robot.maxRotateSpeed		
			robot.rotate(10)	
		}
	}
}