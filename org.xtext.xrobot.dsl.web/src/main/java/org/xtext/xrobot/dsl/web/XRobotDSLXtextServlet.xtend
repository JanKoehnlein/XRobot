/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import com.google.common.collect.Maps
import com.google.inject.Guice
import com.google.inject.Module
import com.google.inject.util.Modules
import java.util.Collections
import java.util.Map
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javax.servlet.annotation.WebServlet
import javax.servlet.http.HttpServletRequest
import org.eclipse.xtext.web.servlet.XtextServlet
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup

@WebServlet(name = "Xtext Services", urlPatterns = "/xtext-service/*")
class XRobotDSLXtextServlet extends XtextServlet {

	ExecutorService executorService

	override init() {
		super.init()
		executorService = Executors.newCachedThreadPool
		new XRobotDSLStandaloneSetup {
			override createInjector() {
				val runtimeModule = new XRobotDSLRuntimeModule as Module
				val webModule = new XRobotDSLWebModule(executorService)
				return Guice.createInjector(Modules.override(runtimeModule).with(webModule))
			}
		}.createInjectorAndDoEMFRegistration
	}

	override destroy() {
		if (executorService !== null)
			executorService.shutdown()
		executorService = null
		super.destroy()
	}
	
	override getParameterMap(HttpServletRequest req) {
		val paramMultiMap = req.parameterMap as Map<String, String[]>
		val result = Maps.newHashMapWithExpectedSize(paramMultiMap.size)
		paramMultiMap.entrySet.filter[value.length > 0].forEach[result.put(key, value.get(0))]
		result.put('remoteAddr', req.remoteAddr)
		return Collections.unmodifiableMap(result)
	}

}
