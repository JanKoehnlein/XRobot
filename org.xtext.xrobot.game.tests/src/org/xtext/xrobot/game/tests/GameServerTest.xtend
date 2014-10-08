package org.xtext.xrobot.game.tests

import org.xtext.xrobot.game.GameServerLauncher

class GameServerTest {
	
	def static void main(String[] args) {
		GameServerLauncher.gameModule = new XRobotTestModule
		GameServerLauncher.main(args)
	}
	
}