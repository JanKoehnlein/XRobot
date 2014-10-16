package org.xtext.xrobot.dsl.tests

import org.xtext.xrobot.dsl.XRobotDSLInjectorProvider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import com.google.inject.Inject
import org.junit.Test
import org.eclipse.xtext.junit4.util.ParseHelper
import org.xtext.xrobot.dsl.xRobotDSL.Program

@RunWith(XtextRunner)
@InjectWith(XRobotDSLInjectorProvider)
class KeywordsAsIdentifiersTest {

	@Inject extension ParseHelper<Program>
	@Inject extension ValidationTestHelper
	
	@Test
	def void testKeywordsAsIdentifiers() {
		'''
			robot foo
			author bar
			
			var int robot = 1
			
			def author(int on, double canceled, boolean when) {
				if(when) canceled + on
			}
			
			Mode on robot != 1 {
			}
		'''.parse.assertNoErrors
	}	
}