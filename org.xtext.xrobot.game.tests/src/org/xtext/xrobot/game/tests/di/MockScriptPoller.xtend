/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import com.google.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.game.GameServer
import org.xtext.xrobot.game.IScriptPoller
import org.xtext.xrobot.game.tests.TestScripts

class MockScriptPoller implements IScriptPoller {
	
	static val LOG = Logger.getLogger(MockScriptPoller)
	
	@Inject GameServer gameServer

	boolean isStopped = false
	
	override start() {
		LOG.debug('Starting script polling thread')
		this.gameServer = gameServer
		isStopped = false
		new Thread([run], 'ScriptPoller') => [
			daemon = true
			priority = 9
			start
		]
	}
	
	override stop() {
		isStopped = true
	}

	private def run() {
		while(!isStopped) {
			Thread.sleep(10000)
			gameServer.register(gameServer.slots.head.token, 'dancer.xrobot', TestScripts.DANCER, false)
			Thread.sleep(2000)
			gameServer.register(gameServer.slots.last.token, 'idle.xrobot', TestScripts.PINGPONG, false)
		}			
	}
	
	@Data
	static class ServerAnswer {
		String _token
		String _sourceCode
	}
}