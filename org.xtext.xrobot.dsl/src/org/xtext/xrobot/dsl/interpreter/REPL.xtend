package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Provider
import com.google.inject.Singleton
import java.io.BufferedReader
import java.io.InputStreamReader
import javax.inject.Inject
import org.eclipse.emf.common.util.BasicDiagnostic
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.StringInputStream
import org.xtext.mindstorms.xrobot.server.RemoteRobot
import org.xtext.mindstorms.xrobot.server.RemoteRobotServer
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.dsl.validation.XRobotDSLValidator
import org.xtext.xrobot.dsl.xRobotDSL.Program
import java.util.regex.Pattern

@Singleton
class REPL {

	def static void main(String[] args) {
		val injector = new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration()
		injector.getInstance(REPL).run
	}

	@Inject Provider<XtextResourceSet> resourceSetProvider
	
	@Inject RemoteRobotServer server
	
	@Inject XRobotDSLValidator validator

	@Inject XRobotInterpreter interpreter

	RemoteRobot _currentRobot

	var indent = 0 

	val loopPattern = Pattern.compile('loop\\s*\\{')

	def run() {
		server.start
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
						line.chars.forEach [ 
							switch it {
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
						val program = parse(model)
						if(program != null) {
							val startTime = System.currentTimeMillis
							var Object result = null
							try {
								result = interpreter.execute(program, currentRobot)
							} catch (StoppedException exc) {
								System.err.println('Stopped by user')
								_currentRobot?.stop
							}
							val duration = System.currentTimeMillis - startTime
							if(result != null) 
								println(result)
							println('(' + duration +'ms)')
						}
					}
				}
			} catch (Exception exc) {
				System.err.println('Error: ' +  exc.message)
				indent = 0
				lines = ''	
			}
		}
		println('Exiting REPL...')
		currentRobot?.stop
		currentRobot?.shutdown
		server.shutdown
		server.join
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
				_currentRobot = server.getRobot(commands.get(1))
			case 'exit',
			case 'quit':
				return false
			case 'list':
				println('Connected robots: ' + server.robotNames.join(', '))
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
				if(currentRobot != null)
					robotName = currentRobot.name
			} catch(Exception exc) {
				_currentRobot = null
			}
			print(robotName + ' > ')
		}
	}
	
	private def Program parse(String model) {
		val resourceSet = resourceSetProvider.get
		val resource = resourceSet.createResource(URI.createURI('dummy.xrobot'))
		resource.load(new StringInputStream(model), null)
		if(!resource.errors.empty) 
			throw new Exception('Syntax Error:\n' + resource.errors.map[ message ].join('\n'))
		val program = resource.contents.head() as Program
		val diagnostic = new BasicDiagnostic
		validator.validate(program, diagnostic, null)
		if(diagnostic.severity == Diagnostic.ERROR) 
			throw new Exception('Error:\n' + diagnostic)
		return program
	}
	
	private def getCurrentRobot() {
		_currentRobot ?: (_currentRobot = server.getRobot(server.robotNames.sort.head))
	}

}
