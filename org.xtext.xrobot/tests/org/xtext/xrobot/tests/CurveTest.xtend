package org.xtext.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot

class CurveSensorTest {
	
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		while(!robot.escapePressed) {
			robot.curveForward(20, 360)
		}
	}
	
}