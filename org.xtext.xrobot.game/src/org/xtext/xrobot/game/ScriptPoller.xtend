package org.xtext.xrobot.game

import com.google.gson.Gson
import java.io.InputStreamReader
import java.net.URL
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Data
import java.io.IOException
import static extension javafx.util.Duration.*

class ScriptPoller {
	
	static val LOG = Logger.getLogger(ScriptPoller)
	
	static val ECLIPSE_SERVER_URL = 'http://10.10.1.3:8081/execute'

	GameServer gameServer

	boolean isStopped = false
	
	def void start(GameServer gameServer) {
		LOG.debug('Starting script polling thread')
		this.gameServer = gameServer
		isStopped = false
		new Thread([run], 'ScriptPoller') => [
			try {
				priority = 9
				start
			} catch(Exception exc) {
				LOG.error('Error polling scripts', exc)
			}
		]
	}
	
	def stop() {
		isStopped = true
	}

	private def run() {
		while(!isStopped) {
			try {
				val urlAsString = '''
					«ECLIPSE_SERVER_URL»?info={_tokens=[«
						FOR token: gameServer.slots.filter[available].map[token.value] SEPARATOR ','
							»"«token»"«
						ENDFOR
					»]}
				'''.toString.trim
				val url = new URL(urlAsString)
				try {
					val resultStream = url.openStream
					val serverAnswer = new Gson().fromJson(new InputStreamReader(resultStream), typeof(ServerAnswer[]))
					serverAnswer?.forEach[
						if(_token != null && _sourceCode != null)
							gameServer.register(new AccessToken(_token), _sourceCode)
					]
					Thread.sleep(500)
				} catch (IOException exc) {
					gameServer.showError('Cannot connect to script server', 2.seconds)
					Thread.sleep(5000)
				}
			} catch (Exception exc) {
				LOG.error('Error connecting to Eclipse server', exc)
			}
		}			
	}
	
	@Data
	static class ServerAnswer {
		String _token
		String _sourceCode
	}
}