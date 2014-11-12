package org.xtext.xrobot.game.demo

import com.google.inject.Inject
import java.util.Random
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.GameServer

import static org.xtext.xrobot.game.demo.ExampleRobot.RobotType.*

class DemoModeHandler extends Thread {
	
	static val DEMO_MODE_IDLE_TIME = 3000
	
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
			val robots = <ExampleRobot>newArrayList
			for (slot : gameServer.slots) {
				var ExampleRobot demoRobot
				do {
					val randomIndex = random.nextInt(exampleProvider.exampleRobots.size)
					demoRobot = exampleProvider.exampleRobots.get(randomIndex)
				} while (demoRobot.type == PASSIVE && !robots.empty && robots.forall[type == PASSIVE])
				robots.add(demoRobot)
				gameServer.register(slot.token, demoRobot.URI, demoRobot.code, true)
			}
		}
	}
	
}