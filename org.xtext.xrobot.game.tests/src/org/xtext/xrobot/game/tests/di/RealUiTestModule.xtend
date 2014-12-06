/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import com.google.inject.Binder
import com.google.inject.Module
import org.xtext.xrobot.game.IErrorReporter
import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ui.GameControlWindow
import org.xtext.xrobot.dsl.XRobotDSLInjectorProvider
import org.eclipse.xtext.xbase.XbaseStandaloneSetup
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import com.google.inject.Guice
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.game.ITimeListener

class RealUiTestModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IErrorReporter).to(Display)
		binder.bind(IGameListener).to(GameControlWindow)
		binder.bind(ITimeListener).to(Display)
	}
	
	
	static class InjectorProvider extends XRobotDSLInjectorProvider {
	
		override internalCreateInjector() {
			XbaseStandaloneSetup.doSetup()
			val injector = Guice.createInjector(new BaseTestModule, new RealUiTestModule,
					new XRobotDSLRuntimeModule)
			new XRobotDSLStandaloneSetup().register(injector)
			injector
		}
		
	}
	
}