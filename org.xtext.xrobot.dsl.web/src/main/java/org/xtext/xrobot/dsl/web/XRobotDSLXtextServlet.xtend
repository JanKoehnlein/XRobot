package org.xtext.xrobot.dsl.web

import com.google.inject.Guice
import com.google.inject.util.Modules
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javax.servlet.annotation.WebServlet
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.eclipse.xtext.web.servlet.XtextServlet
import com.google.inject.Module

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

}
