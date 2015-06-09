/**
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.xtext.xrobot.dsl.web;

import com.google.inject.Inject;
import java.io.File;
import java.io.FileWriter;
import java.util.Map;
import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.web.server.IServiceResult;
import org.eclipse.xtext.web.server.ISessionStore;
import org.eclipse.xtext.web.server.InvalidRequestException;
import org.eclipse.xtext.web.server.ServiceConflictResult;
import org.eclipse.xtext.web.server.XtextServiceDispatcher;
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

@SuppressWarnings("all")
public class XRobotsServiceDispatcher extends XtextServiceDispatcher {
  @Inject
  private IResourceBaseProvider resourceBaseProvider;
  
  @Override
  public XtextServiceDispatcher.ServiceDescriptor createServiceDescriptor(final String requestType, final Map<String, String> parameters, final ISessionStore sessionStore) {
    try {
      XtextServiceDispatcher.ServiceDescriptor _switchResult = null;
      switch (requestType) {
        case "create":
          _switchResult = this.getCreateService(parameters, sessionStore);
          break;
        case "execute":
          _switchResult = this.getExecuteService(parameters, sessionStore);
          break;
        default:
          _switchResult = super.createServiceDescriptor(requestType, parameters, sessionStore);
          break;
      }
      return _switchResult;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  protected XtextServiceDispatcher.ServiceDescriptor getCreateService(final Map<String, String> parameters, final ISessionStore sessionStore) throws InvalidRequestException {
    XtextServiceDispatcher.ServiceDescriptor _xblockexpression = null;
    {
      final String resourceId = parameters.get("resource");
      if ((resourceId == null)) {
        throw new InvalidRequestException(InvalidRequestException.Type.INVALID_PARAMETERS, "The parameter \'resource\' is required.");
      }
      XtextServiceDispatcher.ServiceDescriptor _serviceDescriptor = new XtextServiceDispatcher.ServiceDescriptor();
      final Procedure1<XtextServiceDispatcher.ServiceDescriptor> _function = new Procedure1<XtextServiceDispatcher.ServiceDescriptor>() {
        @Override
        public void apply(final XtextServiceDispatcher.ServiceDescriptor it) {
          final Function0<IServiceResult> _function = new Function0<IServiceResult>() {
            @Override
            public IServiceResult apply() {
              ServiceConflictResult _xtrycatchfinallyexpression = null;
              try {
                final URI uri = XRobotsServiceDispatcher.this.resourceBaseProvider.getFileURI(resourceId);
                String _fileString = uri.toFileString();
                final File file = new File(_fileString);
                boolean _exists = file.exists();
                if (_exists) {
                  return new ServiceConflictResult("The resoruce URI is already reserved.");
                } else {
                  FileWriter writer = null;
                  try {
                    FileWriter _fileWriter = new FileWriter(file);
                    writer = _fileWriter;
                    final String fullText = parameters.get("fullText");
                    if ((fullText != null)) {
                      writer.write(fullText);
                    }
                  } finally {
                    if ((writer != null)) {
                      writer.close();
                    }
                  }
                  return new IServiceResult() {
                  };
                }
              } catch (final Throwable _t) {
                if (_t instanceof Throwable) {
                  final Throwable throwable = (Throwable)_t;
                  _xtrycatchfinallyexpression = XRobotsServiceDispatcher.this.handleError(it, throwable);
                } else {
                  throw Exceptions.sneakyThrow(_t);
                }
              }
              return _xtrycatchfinallyexpression;
            }
          };
          it.setService(_function);
          it.setHasSideEffects(true);
        }
      };
      _xblockexpression = ObjectExtensions.<XtextServiceDispatcher.ServiceDescriptor>operator_doubleArrow(_serviceDescriptor, _function);
    }
    return _xblockexpression;
  }
  
  protected XtextServiceDispatcher.ServiceDescriptor getExecuteService(final Map<String, String> parameters, final ISessionStore sessionStore) throws InvalidRequestException {
    XtextServiceDispatcher.ServiceDescriptor _serviceDescriptor = new XtextServiceDispatcher.ServiceDescriptor();
    final Procedure1<XtextServiceDispatcher.ServiceDescriptor> _function = new Procedure1<XtextServiceDispatcher.ServiceDescriptor>() {
      @Override
      public void apply(final XtextServiceDispatcher.ServiceDescriptor it) {
        final Function0<IServiceResult> _function = new Function0<IServiceResult>() {
          @Override
          public IServiceResult apply() {
            ServiceConflictResult _xtrycatchfinallyexpression = null;
            try {
              _xtrycatchfinallyexpression = null;
            } catch (final Throwable _t) {
              if (_t instanceof Throwable) {
                final Throwable throwable = (Throwable)_t;
                _xtrycatchfinallyexpression = XRobotsServiceDispatcher.this.handleError(it, throwable);
              } else {
                throw Exceptions.sneakyThrow(_t);
              }
            }
            return _xtrycatchfinallyexpression;
          }
        };
        it.setService(_function);
        it.setHasSideEffects(true);
      }
    };
    return ObjectExtensions.<XtextServiceDispatcher.ServiceDescriptor>operator_doubleArrow(_serviceDescriptor, _function);
  }
}
