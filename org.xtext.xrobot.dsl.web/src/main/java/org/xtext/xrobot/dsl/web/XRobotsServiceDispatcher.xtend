/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import com.google.inject.Inject
import java.io.File
import java.io.FileWriter
import java.io.IOException
import java.util.Map
import org.eclipse.xtext.web.server.ISessionStore
import org.eclipse.xtext.web.server.InvalidRequestException
import org.eclipse.xtext.web.server.ServiceConflictResult
import org.eclipse.xtext.web.server.XtextServiceDispatcher
import org.eclipse.xtext.web.server.model.DocumentStateResult
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider

import static org.eclipse.xtext.web.server.InvalidRequestException.Type.*

class XRobotsServiceDispatcher extends XtextServiceDispatcher {
	
	@Inject IResourceBaseProvider resourceBaseProvider
	
	override createServiceDescriptor(String requestType, Map<String, String> parameters, ISessionStore sessionStore) {
		switch requestType {
			case 'create':
				getCreateService(parameters, sessionStore)
			case 'execute':
				getExecuteService(parameters, sessionStore)
			default:
				super.createServiceDescriptor(requestType, parameters, sessionStore)
		}
	}
	
	protected def getCreateService(Map<String, String> parameters, ISessionStore sessionStore) throws InvalidRequestException {
		val resourceId = parameters.get('resource')
		if (resourceId === null)
			throw new InvalidRequestException(INVALID_PARAMETERS, 'The parameter \'resource\' is required.')
		new ServiceDescriptor => [
			service = [
				try {
					val uri = resourceBaseProvider.getFileURI(resourceId)
					val file = new File(uri.toFileString)
					if (file.exists) {
						return new ServiceConflictResult('The resource URI is already reserved.')
					} else {
						var FileWriter writer
						try {
							writer = new FileWriter(file)
							val fullText = parameters.get('fullText')
							if (fullText !== null)
								writer.write(fullText)
						} finally {
							if (writer !== null)
								writer.close()
						}
						val document = getResourceDocument(resourceId, sessionStore, [
							throw new IOException('Failed to create the script file.')
						])
						return new DocumentStateResult(document.stateId)
					}
				} catch (Throwable throwable) {
					handleError(throwable)
				}
			]
			hasSideEffects = true
		]
	}
	
	protected def getExecuteService(Map<String, String> parameters, ISessionStore sessionStore) throws InvalidRequestException {
		val document = getDocumentAccess(parameters, sessionStore)
		val token = parameters.get('token')
		if (token === null)
			throw new InvalidRequestException(INVALID_PARAMETERS, 'The parameter \'token\' is required.')
		val address = parameters.get('remoteAddr')
		if (address === null)
			throw new AssertionError
		new ServiceDescriptor => [
			service = [
				try {
					document.readOnly([ it, cancelIndicator |
						ScriptProviderServlet.tokenStore.add(text, resourceId, token, address)
					])
				} catch (Throwable throwable) {
					handleError(throwable)
				}
			]
			hasSideEffects = true
			hasTextInput = parameters.containsKey('fullText')
		]
	}
	
}