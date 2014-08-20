package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import java.io.InputStream
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.xtext.xrobot.dsl.xRobotDSL.Program

class ParseHelper {
	
	@Inject XtextResourceSet resourceSet
	
	def Program parse(InputStream in) {
		val resource = resourceSet.createResource(URI.createURI('dummy.xrobot'))
		resource.load(in, null)
		return resource.contents.head() as Program
	}
}