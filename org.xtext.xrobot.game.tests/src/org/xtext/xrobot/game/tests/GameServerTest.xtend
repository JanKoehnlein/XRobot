package org.xtext.xrobot.game.tests

import org.xtext.xrobot.game.GameServer

import static org.xtext.xrobot.game.GameServer.*

class GameServerTest {
	
	def static void main(String[] args) {
		GameServer.gameModule = new XRobotTestModule
		GameServer.main(args)
	}
	
}