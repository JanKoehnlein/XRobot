package org.xtext.xrobot.game.demo

import com.google.inject.Inject
import java.util.Random
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.GameServer

class DemoModeHandler extends Thread {
	
	static val DEMO_MODE_IDLE_TIME = 10000
	
	@Accessors(PUBLIC_SETTER)
	boolean cancel
	
	@Inject GameServer gameServer
	
	@Inject ExampleRobot.Provider exampleProvider
	
	val random = new Random
	
	new() {
		super('Demo Mode Handler')
	}
	
	override run() {
		sleep(DEMO_MODE_IDLE_TIME)
		if (gameServer.demoModeActive && !cancel) {
			val candidateRobots = exampleProvider.normalExampleRobots
			for (slot : gameServer.slots) {
				val randomIndex = random.nextInt(candidateRobots.size)
				var ExampleRobot demoRobot = candidateRobots.get(randomIndex)
				gameServer.register(slot.token, demoRobot.URI, demoRobot.code, true)
			}
		}
	}
	
}