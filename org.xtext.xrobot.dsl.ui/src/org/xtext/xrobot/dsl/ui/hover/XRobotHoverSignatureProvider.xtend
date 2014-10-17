package org.xtext.xrobot.dsl.ui.hover

import org.eclipse.xtext.xbase.ui.hover.XbaseDeclarativeHoverSignatureProvider
import org.xtext.xrobot.dsl.xRobotDSL.Field
import org.xtext.xrobot.dsl.xRobotDSL.Sub
import org.eclipse.emf.ecore.EObject
import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations

class XRobotHoverSignatureProvider extends XbaseDeclarativeHoverSignatureProvider {
	
	@Inject extension IJvmModelAssociations 
	
	override getSignature(EObject object) {
		switch primary: object.primarySourceElement {
			Field,
			Sub:
				return super.getSignature(primary)
			default:
				super.getSignature(object)
		}
	}
	
}