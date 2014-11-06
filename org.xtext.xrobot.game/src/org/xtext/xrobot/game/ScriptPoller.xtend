package org.xtext.xrobot.game

import com.google.gson.Gson
import java.io.IOException
import java.io.InputStreamReader
import java.net.URL
import javax.inject.Inject
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Data

import static extension javafx.util.Duration.*

class ScriptPoller implements IScriptPoller {
	
	static val LOG = Logger.getLogger(ScriptPoller)
	
	static val ECLIPSE_SERVER_URL = 'http://xrobots.itemis.de/execute'

	@Inject GameServer gameServer
	@Inject IErrorReporter errorReporter

	boolean isStopped = false
	
	override void start() {
		LOG.debug('Starting script polling thread')
		this.gameServer = gameServer
		isStopped = false
		new Thread([run], 'ScriptPoller') => [
			try {
				daemon = true
				priority = 9
				start
			} catch(Exception exc) {
				LOG.error('Error starting script poller', exc)
			}
		]
	}
	
	override stop() {
		isStopped = true
	}

	private def run() {
		while(!isStopped) {
			try {
				val urlAsString = '''
					«ECLIPSE_SERVER_URL»?info={tokens=[«
						FOR token: gameServer.slots.filter[available].map[token.value] SEPARATOR ','
							»"«token»"«
						ENDFOR
					»]}
				'''.toString.trim
				val url = new URL(urlAsString)
				val resultStream = url.openStream
				val serverAnswer = new Gson().fromJson(new InputStreamReader(resultStream), typeof(ServerAnswer[]))
				serverAnswer?.forEach[
					if (token != null && uri != null && sourceCode != null) {
						gameServer.register(new AccessToken(token), uri, sourceCode)
					}
				]
				Thread.sleep(500)
			} catch (IOException exc) {
				LOG.error('Error connecting to script server', exc)
				errorReporter.showError('Cannot connect to script server', 5.seconds)
				Thread.sleep(5000)
			} catch (Throwable t) {
				LOG.error('Error in script poller', t)
			}
		}
	}
	
	@Data
	static class ServerAnswer {
		long timestamp
		String token
		String uri
		String sourceCode
	}
}