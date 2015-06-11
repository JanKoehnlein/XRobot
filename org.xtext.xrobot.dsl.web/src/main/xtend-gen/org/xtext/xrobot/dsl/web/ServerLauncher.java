/**
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.xtext.xrobot.dsl.web;

import java.net.InetSocketAddress;
import org.eclipse.jetty.annotations.AnnotationConfiguration;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.log.Slf4jLog;
import org.eclipse.jetty.webapp.Configuration;
import org.eclipse.jetty.webapp.MetaInfConfiguration;
import org.eclipse.jetty.webapp.WebAppContext;
import org.eclipse.jetty.webapp.WebInfConfiguration;
import org.eclipse.jetty.webapp.WebXmlConfiguration;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.xtext.xrobot.dsl.web.ScriptProviderServlet;

@SuppressWarnings("all")
public class ServerLauncher {
  public static void main(final String[] args) {
    InetSocketAddress _inetSocketAddress = new InetSocketAddress("localhost", 8080);
    final Server server = new Server(_inetSocketAddress);
    HandlerList _handlerList = new HandlerList();
    final Procedure1<HandlerList> _function = new Procedure1<HandlerList>() {
      @Override
      public void apply(final HandlerList it) {
        WebAppContext _webAppContext = new WebAppContext();
        final Procedure1<WebAppContext> _function = new Procedure1<WebAppContext>() {
          @Override
          public void apply(final WebAppContext it) {
            it.setResourceBase("src/main/webapp");
            it.setWelcomeFiles(new String[] { "entry.html" });
            it.setContextPath("/");
            AnnotationConfiguration _annotationConfiguration = new AnnotationConfiguration();
            WebXmlConfiguration _webXmlConfiguration = new WebXmlConfiguration();
            WebInfConfiguration _webInfConfiguration = new WebInfConfiguration();
            MetaInfConfiguration _metaInfConfiguration = new MetaInfConfiguration();
            it.setConfigurations(new Configuration[] { _annotationConfiguration, _webXmlConfiguration, _webInfConfiguration, _metaInfConfiguration });
            it.setAttribute(WebInfConfiguration.CONTAINER_JAR_PATTERN, ".*org\\.eclipse\\.xtext\\.web.*|.*org\\.eclipse\\.xtext\\.xbase\\.web.*|.*org\\.xtext\\.xrobot\\.dsl\\.web.*|.*requirejs.*|.*jquery.*|.*jqwidgets.*");
          }
        };
        WebAppContext _doubleArrow = ObjectExtensions.<WebAppContext>operator_doubleArrow(_webAppContext, _function);
        it.addHandler(_doubleArrow);
        ServletContextHandler _servletContextHandler = new ServletContextHandler(ServletContextHandler.SESSIONS);
        final Procedure1<ServletContextHandler> _function_1 = new Procedure1<ServletContextHandler>() {
          @Override
          public void apply(final ServletContextHandler it) {
            ScriptProviderServlet _scriptProviderServlet = new ScriptProviderServlet();
            ServletHolder _servletHolder = new ServletHolder(_scriptProviderServlet);
            it.addServlet(_servletHolder, "/scripts");
          }
        };
        ServletContextHandler _doubleArrow_1 = ObjectExtensions.<ServletContextHandler>operator_doubleArrow(_servletContextHandler, _function_1);
        it.addHandler(_doubleArrow_1);
      }
    };
    HandlerList _doubleArrow = ObjectExtensions.<HandlerList>operator_doubleArrow(_handlerList, _function);
    server.setHandler(_doubleArrow);
    String _name = ServerLauncher.class.getName();
    final Slf4jLog log = new Slf4jLog(_name);
    try {
      server.start();
      server.join();
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception exception = (Exception)_t;
        String _message = exception.getMessage();
        log.warn(_message);
        System.exit(1);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}
