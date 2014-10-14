package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Provider
import com.google.inject.Singleton
import java.io.BufferedReader
import java.io.InputStreamReader
import javax.inject.Inject
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobotConnector

@Singleton
class REPL {

	def static void main(String[] args) {
		val injector = new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration()
		injector.getInstance(REPL).run
	}

	@Inject RemoteRobotConnector connector
	
	@Inject Provider<XtextResourceSet> resourceSetProvider
	
	@Inject ScriptParser parser
	
	@Inject ScriptRunner runner
	
	IRemoteRobot.Factory currentRobotFactory

	var indent = 0 

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
					if(indent == 0 && !lines.trim.empty) {
						val model = '''
							MyProg on true {
								«lines»
							}
						''' 
						println(model)
						lines = ''
						val cancelIndicator = new CancelIndicator() {
							volatile boolean canceled
							override isCanceled() {
								canceled = canceled || System.in.available > 0 
							}
						}
						try {
							val resourceSet = resourceSetProvider.get()
							val program = parser.parse('dummy.xrobot', model, resourceSet)
							runner.run(program, currentRobotFactory, cancelIndicator)					
						} catch (CanceledException exc) {
						}
					}
				}
			} catch (Exception exc) {
				System.err.println('Error: ' +  exc.message)
				exc.printStackTrace
				indent = 0
				lines = ''	
			}
		}
		println('Exiting REPL...')
		currentRobotFactory?.release
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
					$discover           list available robots
					$exit|$quit         exit REPL
					<expression>        execute Xbase expression on current robot 'it'
					$                   re-execute previous expression
				''')
			case 'robot':
				currentRobotFactory = connector.getRobotFactory(RobotID.valueOf(commands.get(1)))
			case 'exit',
			case 'quit':
				return false
			case 'discover':
				println('Connected robots: ' + connector.discoverRobots.join(', '))
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
				if(currentRobotFactory == null)
					currentRobotFactory = connector.getRobotFactory(connector.discoverRobots.head)
				if(currentRobotFactory != null)
					robotName = currentRobotFactory.robotID.name
			} catch(Exception exc) {
				currentRobotFactory = null
			}
			print(robotName + ' > ')
		}
	}
	
}
