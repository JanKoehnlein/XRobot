package org.xtext.xrobot.dsl.web;

import java.net.InetSocketAddress;
import org.eclipse.jetty.annotations.AnnotationConfiguration;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.log.Slf4jLog;
import org.eclipse.jetty.webapp.Configuration;
import org.eclipse.jetty.webapp.MetaInfConfiguration;
import org.eclipse.jetty.webapp.WebAppContext;
import org.eclipse.jetty.webapp.WebInfConfiguration;
import org.eclipse.jetty.webapp.WebXmlConfiguration;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class ServerLauncher {
  public static void main(final String[] args) {
    InetSocketAddress _inetSocketAddress = new InetSocketAddress("localhost", 8080);
    final Server server = new Server(_inetSocketAddress);
    WebAppContext _webAppContext = new WebAppContext();
    final Procedure1<WebAppContext> _function = new Procedure1<WebAppContext>() {
      @Override
      public void apply(final WebAppContext it) {
        it.setResourceBase("src/main/webapp");
        it.setWelcomeFiles(new String[] { "index.html" });
        it.setContextPath("/");
        AnnotationConfiguration _annotationConfiguration = new AnnotationConfiguration();
        WebXmlConfiguration _webXmlConfiguration = new WebXmlConfiguration();
        WebInfConfiguration _webInfConfiguration = new WebInfConfiguration();
        MetaInfConfiguration _metaInfConfiguration = new MetaInfConfiguration();
        it.setConfigurations(new Configuration[] { _annotationConfiguration, _webXmlConfiguration, _webInfConfiguration, _metaInfConfiguration });
        it.setAttribute(WebInfConfiguration.CONTAINER_JAR_PATTERN, ".*org\\.eclipse\\.xtext\\.web.*|.*org\\.xtext\\.xrobot\\.ds\\.web.*|.*requirejs.*|.*jquery.*");
      }
    };
    WebAppContext _doubleArrow = ObjectExtensions.<WebAppContext>operator_doubleArrow(_webAppContext, _function);
    server.setHandler(_doubleArrow);
    String _name = ServerLauncher.class.getName();
    final Slf4jLog log = new Slf4jLog(_name);
    try {
      server.start();
      log.info("Press enter to stop the server...");
      final Runnable _function_1 = new Runnable() {
        @Override
        public void run() {
          try {
            final int key = System.in.read();
            server.stop();
            if ((key == (-1))) {
              log.warn("The standard input stream is empty.");
            }
          } catch (Throwable _e) {
            throw Exceptions.sneakyThrow(_e);
          }
        }
      };
      Thread _thread = new Thread(_function_1);
      _thread.start();
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
