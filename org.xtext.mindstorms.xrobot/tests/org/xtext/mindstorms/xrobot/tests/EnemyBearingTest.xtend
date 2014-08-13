package org.xtext.mindstorms.xrobot.tests

import lejos.hardware.BrickFinder
import org.xtext.mindstorms.xrobot.Robot

class EnemyBearingTest {
	def static void main(String[] args) {
		val robot = new Robot(BrickFinder.getDefault)
		while (!robot.escapePressed) {
			println(robot.measureEnemyBearing)
			Thread.sleep(500)
		}
	}
}
