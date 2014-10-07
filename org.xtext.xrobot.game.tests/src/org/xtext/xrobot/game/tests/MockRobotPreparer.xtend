package org.xtext.xrobot.game.tests

import org.xtext.xrobot.game.RobotPreparer
import static org.xtext.xrobot.game.PlayerStatus.*

class MockRobotPreparer extends RobotPreparer {
	
	override void getReady() {
		slot.status = PREPARING
	}
	
	override waitReady() {
		slot.status = READY
	}
	
}