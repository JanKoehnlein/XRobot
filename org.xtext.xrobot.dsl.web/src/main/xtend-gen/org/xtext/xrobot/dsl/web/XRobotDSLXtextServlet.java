/**
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.xtext.xrobot.dsl.web;

import com.google.common.collect.Maps;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;
import com.google.inject.util.Modules;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import org.eclipse.xtext.web.servlet.XtextServlet;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
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
  
  @Override
  public Map<String, String> getParameterMap(final HttpServletRequest req) {
    Map<String, String[]> _parameterMap = req.getParameterMap();
    final Map<String, String[]> paramMultiMap = ((Map<String, String[]>) _parameterMap);
    int _size = paramMultiMap.size();
    final HashMap<String, String> result = Maps.<String, String>newHashMapWithExpectedSize(_size);
    Set<Map.Entry<String, String[]>> _entrySet = paramMultiMap.entrySet();
    final Function1<Map.Entry<String, String[]>, Boolean> _function = new Function1<Map.Entry<String, String[]>, Boolean>() {
      @Override
      public Boolean apply(final Map.Entry<String, String[]> it) {
        String[] _value = it.getValue();
        int _length = _value.length;
        return Boolean.valueOf((_length > 0));
      }
    };
    Iterable<Map.Entry<String, String[]>> _filter = IterableExtensions.<Map.Entry<String, String[]>>filter(_entrySet, _function);
    final Procedure1<Map.Entry<String, String[]>> _function_1 = new Procedure1<Map.Entry<String, String[]>>() {
      @Override
      public void apply(final Map.Entry<String, String[]> it) {
        String _key = it.getKey();
        String[] _value = it.getValue();
        String _get = _value[0];
        result.put(_key, _get);
      }
    };
    IterableExtensions.<Map.Entry<String, String[]>>forEach(_filter, _function_1);
    String _remoteAddr = req.getRemoteAddr();
    result.put("remoteAddr", _remoteAddr);
    return Collections.<String, String>unmodifiableMap(result);
  }
}
