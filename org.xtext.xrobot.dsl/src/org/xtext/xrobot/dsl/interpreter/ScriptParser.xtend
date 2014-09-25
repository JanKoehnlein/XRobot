package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import org.eclipse.emf.common.util.BasicDiagnostic
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.StringInputStream
import org.xtext.xrobot.dsl.validation.XRobotDSLValidator
import org.xtext.xrobot.dsl.xRobotDSL.Program

class ScriptParser {
	
	@Inject XRobotDSLValidator validator
	
	def Program parse(String model, XtextResourceSet resourceSet) {
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