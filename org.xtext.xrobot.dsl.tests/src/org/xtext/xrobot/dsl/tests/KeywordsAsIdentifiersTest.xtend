/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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
			
			def author(int on, double left, boolean when) {
				if (when) left + on
			}
			
			Mode on robot != 1 {
			}
		'''.parse.assertNoErrors
	}	
}