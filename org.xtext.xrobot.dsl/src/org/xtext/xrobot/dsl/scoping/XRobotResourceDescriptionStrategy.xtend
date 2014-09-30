package org.xtext.xrobot.dsl.scoping

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IReferenceDescription
import org.eclipse.xtext.util.IAcceptor

class XRobotResourceDescriptionStrategy implements IDefaultResourceDescriptionStrategy {
	
	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		// don't export any object, so nothing will be referable from the outside 
		false
	}
	
	override createReferenceDescriptions(EObject eObject, URI exportedContainerURI, IAcceptor<IReferenceDescription> acceptor) {
		// we don't have cross-resource references 
		false
	}
	
}