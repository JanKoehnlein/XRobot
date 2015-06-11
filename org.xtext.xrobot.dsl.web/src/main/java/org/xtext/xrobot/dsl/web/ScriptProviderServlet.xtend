/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import com.google.gson.Gson
import java.io.IOException
import javax.servlet.ServletException
import javax.servlet.http.HttpServlet
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.eclipse.xtend.lib.annotations.Data

class ScriptProviderServlet extends HttpServlet {
	
	static ReservedTokenStore reservedTokenStore
	
	static def getTokenStore() {
		if (reservedTokenStore === null) {
			reservedTokenStore = new ReservedTokenStore
		}
		return reservedTokenStore
	}
	
	override doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		val gson = new Gson
		val parameter = request.getParameter('info')
		val queryByToken = gson.fromJson(parameter, QueryByToken)
		val store = getTokenStore
		val matches = queryByToken?.tokens?.map[store.get(it)].filterNull.toList
		response.setContentType("text/x-json;charset=UTF-8")
		response.setHeader("Cache-Control", "no-cache")
		response.setStatus(HttpServletResponse::SC_OK)
		gson.toJson(matches, response.writer)
	}
	
	@Data
	public static class QueryByToken {
		String[] tokens
	}
	
}
