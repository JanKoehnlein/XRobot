package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.concurrent.CopyOnWriteArrayList
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.BasicDiagnostic
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.StringInputStream
import org.xtext.xrobot.dsl.validation.XRobotDSLValidator
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.RemoteRobotFactory

class ScriptRunner {

	static val LOG = Logger.getLogger(ScriptRunner)

	@Inject XRobotDSLValidator validator

	@Inject Provider<XRobotInterpreter> interpreterProvider
	
	val listeners = new CopyOnWriteArrayList<IRobotListener>

	def addRobotListener(IRobotListener listener) {
		listeners += listener
	}

	def void run(RemoteRobotFactory robotFactory, String model, XtextResourceSet resourceSet, CancelIndicator cancelIndicator) {
		val program = model.parse(resourceSet)
		if(program != null && robotFactory != null) {
			try {
				interpreterProvider.get.execute(program, robotFactory, listeners, cancelIndicator)
			} catch (CanceledException exc) {
				LOG.info('Canceled')
			}
		}
	}

	private def Program parse(String model, XtextResourceSet resourceSet) {
		val resource = resourceSet.createResource(URI.createURI('Dummy.xrobot'))
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
