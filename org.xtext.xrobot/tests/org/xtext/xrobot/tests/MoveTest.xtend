package org.xtext.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot

class WeaponTest {
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		robot.drivingSpeed = robot.maxDrivingSpeed
		while (!robot.escapePressed) {
			robot.drive(30)
			robot.drive(30)
			robot.drive(-30)
			robot.drive(30)
			robot.drive(-30)
			robot.drive(30)
			Thread.sleep(400)			
			robot.curveForward(20, 360)
			Thread.sleep(400)
			robot.rotate(360)
			Thread.sleep(400)			
		}
	}
}