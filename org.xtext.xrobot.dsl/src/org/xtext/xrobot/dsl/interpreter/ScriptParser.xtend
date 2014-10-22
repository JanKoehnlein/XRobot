package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import org.eclipse.emf.common.util.BasicDiagnostic
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.StringInputStream
import org.xtext.xrobot.dsl.validation.XRobotDSLValidator
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID

class ScriptParser {

	@Inject XRobotDSLValidator validator
	
	@Accessors
	RobotID robotID

	def Program parse(String uri, String model, XtextResourceSet resourceSet) {
		val label = if (robotID == null) 'Parser' else robotID.toString
		val resource = resourceSet.createResource(URI.createURI(uri))
		resource.load(new StringInputStream(model), null)
		if (!resource.errors.empty)
			throw new Exception(label + ' syntax error:\n' + resource.errors.map[message].join('\n'))
		val program = resource.contents.head() as Program
		val diagnostic = new BasicDiagnostic
		validator.validate(program, diagnostic, null)
		if (diagnostic.severity == Diagnostic.ERROR)
			throw new Exception(label + ' error:\n' + diagnostic)
		return program
	}

}
