/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.ui.hover

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations
import org.eclipse.xtext.xbase.ui.hover.XbaseDeclarativeHoverSignatureProvider
import org.xtext.xrobot.dsl.xRobotDSL.Function
import org.xtext.xrobot.dsl.xRobotDSL.Variable

class XRobotHoverSignatureProvider extends XbaseDeclarativeHoverSignatureProvider {
	
	@Inject extension IJvmModelAssociations 
	
	override getSignature(EObject object) {
		switch primary: object.primarySourceElement {
			Variable,
			Function:
				return super.getSignature(primary)
			default:
				super.getSignature(object)
		}
	}
	
}