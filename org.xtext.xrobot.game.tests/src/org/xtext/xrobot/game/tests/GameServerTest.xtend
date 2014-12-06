/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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