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