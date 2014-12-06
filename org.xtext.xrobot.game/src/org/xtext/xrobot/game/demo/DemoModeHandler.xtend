/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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