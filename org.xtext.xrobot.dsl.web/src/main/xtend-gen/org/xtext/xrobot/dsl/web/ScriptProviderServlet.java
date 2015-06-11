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
public class ScriptProviderServlet extends HttpServlet {
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
      ScriptProviderServlet.QueryByToken other = (ScriptProviderServlet.QueryByToken) obj;
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
  
  private static ReservedTokenStore reservedTokenStore;
  
  public static ReservedTokenStore getTokenStore() {
    if ((ScriptProviderServlet.reservedTokenStore == null)) {
      ReservedTokenStore _reservedTokenStore = new ReservedTokenStore();
      ScriptProviderServlet.reservedTokenStore = _reservedTokenStore;
    }
    return ScriptProviderServlet.reservedTokenStore;
  }
  
  @Override
  public void doGet(final HttpServletRequest request, final HttpServletResponse response) throws ServletException, IOException {
    final Gson gson = new Gson();
    final String parameter = request.getParameter("info");
    final ScriptProviderServlet.QueryByToken queryByToken = gson.<ScriptProviderServlet.QueryByToken>fromJson(parameter, ScriptProviderServlet.QueryByToken.class);
    final ReservedTokenStore store = ScriptProviderServlet.getTokenStore();
    String[] _kens = null;
    if (queryByToken!=null) {
      _kens=queryByToken.tokens;
    }
    List<ReservedTokenStore.Entry> _map = null;
    if (((List<String>)Conversions.doWrapArray(_kens))!=null) {
      final Function1<String, ReservedTokenStore.Entry> _function = new Function1<String, ReservedTokenStore.Entry>() {
        @Override
        public ReservedTokenStore.Entry apply(final String it) {
          return store.get(it);
        }
      };
      _map=ListExtensions.<String, ReservedTokenStore.Entry>map(((List<String>)Conversions.doWrapArray(_kens)), _function);
    }
    Iterable<ReservedTokenStore.Entry> _filterNull = IterableExtensions.<ReservedTokenStore.Entry>filterNull(_map);
    final List<ReservedTokenStore.Entry> matches = IterableExtensions.<ReservedTokenStore.Entry>toList(_filterNull);
    response.setContentType("text/x-json;charset=UTF-8");
    response.setHeader("Cache-Control", "no-cache");
    response.setStatus(HttpServletResponse.SC_OK);
    PrintWriter _writer = response.getWriter();
    gson.toJson(matches, _writer);
  }
}
