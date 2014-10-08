package org.xtext.xrobot.game.tests.di

import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.IRobotPreparer
import org.xtext.xrobot.game.PlayerSlot

import static org.xtext.xrobot.game.PlayerStatus.*

class MockRobotPreparer implements IRobotPreparer {
	
	static val LOG = Logger.getLogger(MockRobotPreparer)
	
	@Accessors(PUBLIC_SETTER)
	PlayerSlot slot
	
	override prepare() {
		LOG.debug("preparing")
		slot.status = PREPARING
	}
	
	override waitReady() {
		LOG.debug("ready")
		slot.status = READY
	}
	
}