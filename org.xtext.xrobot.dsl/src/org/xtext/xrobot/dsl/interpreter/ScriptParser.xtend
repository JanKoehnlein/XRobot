package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.parser.ParseException
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.StringInputStream
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.xtext.xrobot.dsl.xRobotDSL.Program

import static org.eclipse.xtext.diagnostics.Severity.*

/**
 * Utility class for parsing and validating XRobot scripts.
 */
class ScriptParser {

	@Inject IResourceValidator validator
	
	@Accessors(PUBLIC_SETTER)
	boolean validate = true

	/**
	 * Parse the given model.
	 * 
	 * @throws ParseException if the model contains errors
	 */
	def Program parse(String uri, String model, XtextResourceSet resourceSet,
			CancelIndicator cancelIndicator) {
		val resource = resourceSet.createResource(URI.createURI(uri))
		resource.load(new StringInputStream(model), null)
		if (!resource.errors.empty)
			throw new ParseException('Syntax error:\n'
					+ resource.errors.map[message].join('\n'))
		
		if (validate) {
			val issues = validator.validate(resource, CheckMode.ALL,
					cancelIndicator ?: CancelIndicator.NullImpl)
			if (issues.exists[severity == ERROR])
				throw new ParseException('Validation error:\n'
						+ issues.filter[severity == ERROR].map[message].join('\n'))
		}
		
		resource.contents.head() as Program
	}

}
