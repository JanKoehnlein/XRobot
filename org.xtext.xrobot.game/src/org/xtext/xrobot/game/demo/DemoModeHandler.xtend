package org.xtext.xrobot.game.demo

import com.google.inject.Inject
import java.util.Random
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.GameServer

class DemoModeHandler extends Thread {
	
	static val DEMO_MODE_IDLE_TIME = 3000
	
	@Accessors(PUBLIC_SETTER)
	boolean cancel
	
	@Inject GameServer gameServer
	
	@Inject ExampleRobot.Provider exampleProvider
	
	new() {
		super('Demo Mode Handler')
	}
	
	override run() {
		sleep(DEMO_MODE_IDLE_TIME)
		if (gameServer.demoModeActive && !cancel) {
			val random = new Random
			for (slot : gameServer.slots) {
				val randomIndex = random.nextInt(exampleProvider.exampleRobots.size)
				val demoRobot = exampleProvider.exampleRobots.get(randomIndex)
				gameServer.register(slot.token, demoRobot.URI, demoRobot.code)
			}
		}
	}
	
}