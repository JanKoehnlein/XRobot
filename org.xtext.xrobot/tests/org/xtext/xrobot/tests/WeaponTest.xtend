package org.xtext.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot

class WeaponTest {
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		while (!robot.escapePressed) {
			robot.scoop(180)
			robot.scoop(0)
			Thread.sleep(500)
		}
	}
}