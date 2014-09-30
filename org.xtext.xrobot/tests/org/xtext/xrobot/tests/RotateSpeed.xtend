package org.xtext.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot

class RotateSpeed {
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		while (!robot.escapePressed) {
			robot.rotationSpeed = 1
			robot.rotate(10)	
			robot.rotationSpeed = robot.maxRotationSpeed		
			robot.rotate(10)	
		}
	}
}