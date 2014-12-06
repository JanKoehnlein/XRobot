/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.scoping

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.common.types.JvmIdentifiableElement
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations
import org.eclipse.xtext.xbase.scoping.batch.FeatureScopes
import org.eclipse.xtext.xbase.scoping.batch.IFeatureScopeSession
import org.eclipse.xtext.xbase.typesystem.references.LightweightTypeReference
import org.xtext.xrobot.dsl.xRobotDSL.Mode

class XRobotFeatureScopes extends FeatureScopes {
	
	@Inject
	private extension  IJvmModelAssociations 

	/**
	 * Disallow referencing artificial methods derived from modes 
	 */	
	override protected createFeatureScopeForTypeRef(XExpression receiver, LightweightTypeReference featureDeclarator, boolean implicit, EObject featureCall, IFeatureScopeSession session, JvmIdentifiableElement receiverFeature, IScope parent, boolean validStaticScope) {
		val superScope = super.createFeatureScopeForTypeRef(receiver, featureDeclarator, implicit, featureCall, session, receiverFeature, parent, validStaticScope)
		new FilteringScope(superScope, [
			return !(EObjectOrProxy?.primarySourceElement instanceof Mode)  
		])
	}
	
}