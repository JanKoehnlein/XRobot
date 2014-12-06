/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.imports

import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.xbase.imports.DefaultImportsConfiguration
import static extension org.eclipse.xtext.nodemodel.util.NodeModelUtils.*

class XRobotImportsConfiguration extends DefaultImportsConfiguration {
	
	override getImportSectionOffset(XtextResource resource) {
		val head = resource.contents.head
		val node = head?.findActualNodeFor
		if(node != null) 
			node.offset
		else
		 	0
	}
}