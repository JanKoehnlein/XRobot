/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider

class XRobotsResourceBaseProvider implements IResourceBaseProvider {
	
	override getFileURI(String resourceId) {
		URI.createFileURI('user-files' + File.separator + resourceId)
	}
	
}