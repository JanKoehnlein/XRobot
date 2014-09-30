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
	
	override protected createFeatureScopeForTypeRef(XExpression receiver, LightweightTypeReference featureDeclarator, boolean implicit, EObject featureCall, IFeatureScopeSession session, JvmIdentifiableElement receiverFeature, IScope parent, boolean validStaticScope) {
		val superScope = super.createFeatureScopeForTypeRef(receiver, featureDeclarator, implicit, featureCall, session, receiverFeature, parent, validStaticScope)
		new FilteringScope(superScope, [
			return !(EObjectOrProxy?.primarySourceElement instanceof Mode)  
		])
	}
	
}