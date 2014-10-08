package org.xtext.xrobot.dsl.scoping

import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.xbase.scoping.XImportSectionNamespaceScopeProvider

class XRobotImportedNamespaceScopeProvider extends XImportSectionNamespaceScopeProvider {
	
	static val ORG_XTEXT_XROBOT_API = QualifiedName.create('org.xtext.xrobot.api')
	
	override getImplicitImports(boolean ignoreCase) {
		val fromSuper = super.getImplicitImports(false)
		fromSuper.add(doCreateImportNormalizer(ORG_XTEXT_XROBOT_API, true, false))
		return fromSuper
	}
	
}