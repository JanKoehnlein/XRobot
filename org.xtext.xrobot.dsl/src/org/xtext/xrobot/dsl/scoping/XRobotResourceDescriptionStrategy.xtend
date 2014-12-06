/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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