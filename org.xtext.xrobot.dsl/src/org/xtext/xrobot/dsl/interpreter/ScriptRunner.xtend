package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import org.eclipse.emf.common.util.BasicDiagnostic
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.StringInputStream
import org.xtext.xrobot.dsl.validation.XRobotDSLValidator
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.RemoteRobot

class ScriptRunner {

	@Inject XRobotDSLValidator validator

	@Inject XRobotInterpreter interpreter
	
	def run(RemoteRobot robot, String model, XtextResourceSet resourceSet, CancelIndicator cancelIndicator) {
		val program = model.parse(resourceSet)
		if(program != null && robot != null) {
			var Object result = null
			try {
				result = interpreter.execute(program, robot, cancelIndicator)
			} catch (StoppedException exc) {
				System.err.println('Stopped by user')
				robot?.stop
			}
			return result
		}
	}

	private def Program parse(String model, XtextResourceSet resourceSet) {
		val resource = resourceSet.createResource(URI.createURI('dummy.xrobot'))
		resource.load(new StringInputStream(model), null)
		if (!resource.errors.empty)
			throw new Exception('Syntax Error:\n' + resource.errors.map[message].join('\n'))
		val program = resource.contents.head() as Program
		val diagnostic = new BasicDiagnostic
		validator.validate(program, diagnostic, null)
		if (diagnostic.severity == Diagnostic.ERROR)
			throw new Exception('Error:\n' + diagnostic)
		return program
	}
}
