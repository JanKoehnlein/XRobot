package org.xtext.mindstorms.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.mindstorms.xrobot.Robot

class CurveSensorTest {
	
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		while(!robot.escapePressed) {
			robot.curveForward(20, 360)
		}
	}
	
}