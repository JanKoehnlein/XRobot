package org.xtext.xrobot.game.tests.di

import com.google.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.game.GameServer
import org.xtext.xrobot.game.IScriptPoller
import org.xtext.xrobot.game.tests.ITestScripts

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
			gameServer.register(gameServer.slots.head.token, ITestScripts.DANCER)
			Thread.sleep(2000)
			gameServer.register(gameServer.slots.last.token, ITestScripts.IDLE)
		}			
	}
	
	@Data
	static class ServerAnswer {
		String _token
		String _sourceCode
	}
}