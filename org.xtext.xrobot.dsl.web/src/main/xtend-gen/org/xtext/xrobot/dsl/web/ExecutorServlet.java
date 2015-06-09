/**
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.xtext.xrobot.dsl.web;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;
import org.xtext.xrobot.dsl.web.ReservedTokenStore;

@SuppressWarnings("all")
public class ExecutorServlet extends HttpServlet {
  @Data
  public static class QueryByToken {
    private final String[] tokens;
    
    public QueryByToken(final String[] tokens) {
      super();
      this.tokens = tokens;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.tokens== null) ? 0 : Arrays.deepHashCode(this.tokens));
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      ExecutorServlet.QueryByToken other = (ExecutorServlet.QueryByToken) obj;
      if (this.tokens == null) {
        if (other.tokens != null)
          return false;
      } else if (!Arrays.deepEquals(this.tokens, other.tokens))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("tokens", this.tokens);
      return b.toString();
    }
    
    @Pure
    public String[] getTokens() {
      return this.tokens;
    }
  }
  
  @Override
  protected void doGet(final HttpServletRequest req, final HttpServletResponse resp) throws ServletException, IOException {
    final Gson gson = new Gson();
    final String parameter = req.getParameter("info");
    final ExecutorServlet.QueryByToken queryByToken = gson.<ExecutorServlet.QueryByToken>fromJson(parameter, ExecutorServlet.QueryByToken.class);
    String[] _kens = null;
    if (queryByToken!=null) {
      _kens=queryByToken.tokens;
    }
    List<ReservedTokenStore.Entry> _map = null;
    if (((List<String>)Conversions.doWrapArray(_kens))!=null) {
      final Function1<String, ReservedTokenStore.Entry> _function = new Function1<String, ReservedTokenStore.Entry>() {
        @Override
        public ReservedTokenStore.Entry apply(final String it) {
          ReservedTokenStore _tokenStore = ExecutorServlet.this.getTokenStore();
          return _tokenStore.get(it);
        }
      };
      _map=ListExtensions.<String, ReservedTokenStore.Entry>map(((List<String>)Conversions.doWrapArray(_kens)), _function);
    }
    Iterable<ReservedTokenStore.Entry> _filterNull = IterableExtensions.<ReservedTokenStore.Entry>filterNull(_map);
    final List<ReservedTokenStore.Entry> matches = IterableExtensions.<ReservedTokenStore.Entry>toList(_filterNull);
    resp.setContentType("text/x-json;charset=UTF-8");
    resp.setHeader("Cache-Control", "no-cache");
    resp.setStatus(HttpServletResponse.SC_OK);
    final String json = gson.toJson(matches);
    PrintWriter _writer = resp.getWriter();
    _writer.write(json);
  }
  
  private ReservedTokenStore getTokenStore() {
    ServletContext _servletContext = this.getServletContext();
    Object attribute = _servletContext.getAttribute("xrobotTokenStore");
    if ((!(attribute instanceof ReservedTokenStore))) {
      ReservedTokenStore _reservedTokenStore = new ReservedTokenStore();
      attribute = _reservedTokenStore;
      ServletContext _servletContext_1 = this.getServletContext();
      _servletContext_1.setAttribute("xrobotTokenStore", attribute);
    }
    return ((ReservedTokenStore) attribute);
  }
}
