package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Singleton
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.regex.Pattern
import javax.inject.Inject
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.server.RemoteRobot
import org.xtext.xrobot.server.RemoteRobotConnector
import com.google.inject.Provider
import org.eclipse.xtext.resource.XtextResourceSet

@Singleton
class REPL {

	def static void main(String[] args) {
		val injector = new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration()
		injector.getInstance(REPL).run
	}

	@Inject RemoteRobotConnector connector
	
	@Inject ScriptRunner runner
	
	@Inject Provider<XtextResourceSet> resourceSetProvider;

	RemoteRobot currentRobot

	var indent = 0 

	val loopPattern = Pattern.compile('loop\\s*\\{')

	def run() {
		val reader = new BufferedReader(new InputStreamReader(System.in))
		var continue = true
		var lines = ''
		println('''
			XRobot Shell - enter '$help' for help
		''')
		while (continue) {
			try {
				prompt()
				val line = reader.readLine.trim
				if(line.startsWith('$')) {
					continue = processShellCommand(line)
				} else {
					for(var i=0; i<indent; i++) {
						lines += '   '
					}
					lines += line
					lines += '\n'
					if(line.contains('{') || line.contains('}')) {
						line.toCharArray.forEach [ 
							switch it as int {
								case 123: indent++
								case 125: indent--
							}
						]
					}
					if(indent < 0) 
						throw new Exception('Mismatched curly braces')	
					if(indent == 0) {
						val runLoop = loopPattern.matcher(lines).find
						val model = if(runLoop) '''
								program MyProg «lines»
							''' else '''
								program MyProg main {
									«lines»
								}
							'''
						println(model)
						lines = ''
						val startTime = System.currentTimeMillis
						val result = runner.run(currentRobot, model, resourceSetProvider.get(), new CancelIndicator() {
							override isCanceled() {
								System.in.available > 0
							}
						})					
						val duration = System.currentTimeMillis - startTime
						if (result != null)
							println(result)
						println('(' + duration + 'ms)')
					}
				}
			} catch (Exception exc) {
				System.err.println('Error: ' +  exc.message)
				indent = 0
				lines = ''	
			}
		}
		println('Exiting REPL...')
		currentRobot?.release
		println('...finished')
	}
	
	def processShellCommand(String line) {
		val commands = line.substring(1).split('\\s')
		switch (commands.head) {
			case null,
			case 'help':
				println('''
					$help               print this text
					$robot <name>       switch current robot
					$list               list connected robots
					$exit|$quit         exit REPL
					<expression>        execute Xbase expression on current robot 'it'
					$                   re-execute previous expression
				''')
			case 'robot':
				currentRobot = connector.getRobot(commands.get(1))
			case 'exit',
			case 'quit':
				return false
			case 'list':
				println('Connected robots: ' + connector.robotNames.join(', '))
			default: 
				println('Invalid command. Enter \'$\' for help')
		}
		return true
	}
	
	private def prompt() {
		if(indent > 0) {
			print('<' + indent +'>')
			for(i:0..<indent)
				print('  ')
		} else {
			var robotName = '(unconnected)'
			try {
				if(currentRobot == null)
					currentRobot = connector.getRobot(connector.robotNames.head)
				if(currentRobot != null)
					robotName = currentRobot.name
			} catch(Exception exc) {
				currentRobot = null
			}
			print(robotName + ' > ')
		}
	}
	
}
