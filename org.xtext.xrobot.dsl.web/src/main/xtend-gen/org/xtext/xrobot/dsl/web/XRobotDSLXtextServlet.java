/**
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.xtext.xrobot.dsl.web;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;
import com.google.inject.util.Modules;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.servlet.annotation.WebServlet;
import org.eclipse.xtext.web.servlet.XtextServlet;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule;
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup;
import org.xtext.xrobot.dsl.web.XRobotDSLWebModule;

@WebServlet(name = "Xtext Services", urlPatterns = "/xtext-service/*")
@SuppressWarnings("all")
public class XRobotDSLXtextServlet extends XtextServlet {
  private ExecutorService executorService;
  
  @Override
  public void init() {
    try {
      super.init();
      ExecutorService _newCachedThreadPool = Executors.newCachedThreadPool();
      this.executorService = _newCachedThreadPool;
      new XRobotDSLStandaloneSetup() {
        @Override
        public Injector createInjector() {
          XRobotDSLRuntimeModule _xRobotDSLRuntimeModule = new XRobotDSLRuntimeModule();
          final Module runtimeModule = ((Module) _xRobotDSLRuntimeModule);
          final XRobotDSLWebModule webModule = new XRobotDSLWebModule(XRobotDSLXtextServlet.this.executorService);
          Modules.OverriddenModuleBuilder _override = Modules.override(runtimeModule);
          Module _with = _override.with(webModule);
          return Guice.createInjector(_with);
        }
      }.createInjectorAndDoEMFRegistration();
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Override
  public void destroy() {
    if ((this.executorService != null)) {
      this.executorService.shutdown();
    }
    this.executorService = null;
    super.destroy();
  }
}
