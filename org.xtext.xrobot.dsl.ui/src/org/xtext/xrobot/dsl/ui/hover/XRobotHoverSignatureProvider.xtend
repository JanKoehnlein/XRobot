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