package org.xtext.xrobot.game.tests.di

import com.google.inject.Binder
import com.google.inject.Guice
import com.google.inject.Module
import org.eclipse.xtext.xbase.XbaseStandaloneSetup
import org.xtext.xrobot.dsl.XRobotDSLInjectorProvider
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.game.IErrorReporter
import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.ITimeListener

class MockUiTestModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IErrorReporter).to(MockErrorReporter)
		binder.bind(IGameListener).to(MockGameListener)
		binder.bind(ITimeListener).to(MockTimeListener)
	}
	
	
	static class InjectorProvider extends XRobotDSLInjectorProvider {
	
		override internalCreateInjector() {
			XbaseStandaloneSetup.doSetup()
			val injector = Guice.createInjector(new BaseTestModule, new MockUiTestModule,
					new XRobotDSLRuntimeModule)
			new XRobotDSLStandaloneSetup().register(injector)
			injector
		}
		
	}
	
}