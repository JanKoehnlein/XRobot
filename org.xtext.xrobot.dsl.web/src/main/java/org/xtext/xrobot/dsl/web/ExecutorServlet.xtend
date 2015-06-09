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

class ExecutorServlet extends HttpServlet {
	
	override protected doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		val gson = new Gson();
		val parameter = req.getParameter('info')
		val queryByToken = gson.fromJson(parameter, QueryByToken)
		val matches = queryByToken?.tokens?.map[tokenStore.get(it)].filterNull.toList
		resp.setContentType("text/x-json;charset=UTF-8");
		resp.setHeader("Cache-Control", "no-cache");
		resp.setStatus(HttpServletResponse::SC_OK);
		val json = gson.toJson(matches);
		resp.getWriter().write(json);	
	}
	
	private def getTokenStore() {
		var attribute = servletContext.getAttribute('xrobotTokenStore')
		if (!(attribute instanceof ReservedTokenStore)) {
			attribute = new ReservedTokenStore
			servletContext.setAttribute('xrobotTokenStore', attribute)			
		} 
		return attribute as ReservedTokenStore
	}
	
	@Data
	public static class QueryByToken {
		String[] tokens
	}
	
}
