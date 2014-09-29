package org.xtext.xrobot.game

import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Data

class MockScriptPoller {
	
	static val LOG = Logger.getLogger(ScriptPoller)
	
	GameServer gameServer

	boolean isStopped = false
	
	def void start(GameServer gameServer) {
		LOG.debug('Starting script polling thread')
		this.gameServer = gameServer
		isStopped = false
		new Thread([run], 'ScriptPoller') => [
			priority = 9
			start
		]
	}
	
	def stop() {
		isStopped = true
	}

	private def run() {
		while(!isStopped) {
			Thread.sleep(2000)
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