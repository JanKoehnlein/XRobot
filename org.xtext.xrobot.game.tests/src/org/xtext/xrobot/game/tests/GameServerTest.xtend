package org.xtext.xrobot.game.tests

import org.xtext.xrobot.game.GameServerApp

class GameServerTest {
	
	def static void main(String[] args) {
		GameServerApp.gameModule = new XRobotTestModule
		GameServerApp.main(args)
	}
	
}