/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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