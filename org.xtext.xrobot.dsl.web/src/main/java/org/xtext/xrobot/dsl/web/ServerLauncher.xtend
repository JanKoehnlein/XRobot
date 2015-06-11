/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import java.net.InetSocketAddress
import org.eclipse.jetty.annotations.AnnotationConfiguration
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.server.handler.HandlerList
import org.eclipse.jetty.servlet.ServletContextHandler
import org.eclipse.jetty.servlet.ServletHolder
import org.eclipse.jetty.util.log.Slf4jLog
import org.eclipse.jetty.webapp.MetaInfConfiguration
import org.eclipse.jetty.webapp.WebAppContext
import org.eclipse.jetty.webapp.WebInfConfiguration
import org.eclipse.jetty.webapp.WebXmlConfiguration

class ServerLauncher {
	def static void main(String[] args) {
		val server = new Server(new InetSocketAddress('localhost', 8080))
		server.handler = new HandlerList => [
			addHandler(new WebAppContext => [
				resourceBase = 'src/main/webapp'
				welcomeFiles = #["entry.html"]
				contextPath = "/"
				configurations = #[
					new AnnotationConfiguration,
					new WebXmlConfiguration,
					new WebInfConfiguration,
					new MetaInfConfiguration
				]
				setAttribute(WebInfConfiguration.CONTAINER_JAR_PATTERN, ".*org\\.eclipse\\.xtext\\.web.*|.*org\\.eclipse\\.xtext\\.xbase\\.web.*|.*org\\.xtext\\.xrobot\\.dsl\\.web.*|.*requirejs.*|.*jquery.*|.*jqwidgets.*")
			])
			addHandler(new ServletContextHandler(ServletContextHandler.SESSIONS) => [
				addServlet(new ServletHolder(new ScriptProviderServlet), '/scripts')
			])
		]
		val log = new Slf4jLog(ServerLauncher.name)
		try {
			server.start
			server.join
		} catch (Exception exception) {
			log.warn(exception.message)
			System.exit(1)
		}
	}
}
