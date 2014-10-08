package org.xtext.xrobot.game.tests

import org.eclipse.xtext.service.CompoundModule
import org.xtext.xrobot.game.GameServerLauncher
import org.xtext.xrobot.game.tests.di.BaseTestModule
import org.xtext.xrobot.game.tests.di.RealUiTestModule

import static org.xtext.xrobot.game.GameServerLauncher.*

class GameServerTest {
	
	def static void main(String[] args) {
		val module = new CompoundModule
		module.add(new BaseTestModule)
		module.add(new RealUiTestModule)
		GameServerLauncher.gameModule = module
		GameServerLauncher.main(args)
	}
	
}