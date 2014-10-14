package org.xtext.xrobot.game.tests.di

import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.IRobotPreparer
import org.xtext.xrobot.game.PlayerSlot

import static org.xtext.xrobot.game.PlayerStatus.*

class MockRobotPreparer implements IRobotPreparer {
	
	@Accessors(PUBLIC_SETTER)
	PlayerSlot slot
	
	override prepare() {
		slot.status = PREPARING
	}
	
	override waitReady() {
		slot.status = READY
	}
	
}