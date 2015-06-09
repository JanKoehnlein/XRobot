/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import com.google.inject.Binder
import com.google.inject.name.Names
import java.util.concurrent.ExecutorService
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ide.LexerIdeBindings
import org.eclipse.xtext.ide.editor.contentassist.antlr.IContentAssistParser
import org.eclipse.xtext.ide.editor.contentassist.antlr.internal.Lexer
import org.eclipse.xtext.web.server.persistence.FileResourceHandler
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler
import org.eclipse.xtext.xbase.web.DefaultXbaseWebModule
import org.xtext.xrobot.dsl.ide.contentassist.antlr.XRobotDSLParser
import org.xtext.xrobot.dsl.ide.contentassist.antlr.internal.InternalXRobotDSLLexer

@Accessors
@FinalFieldsConstructor
class XRobotDSLWebModule extends DefaultXbaseWebModule {

	val ExecutorService executorService

	def configureExecutorService(Binder binder) {
		binder.bind(ExecutorService).toInstance(executorService)
	}

	def configureContentAssistLexer(Binder binder) {
		binder.bind(Lexer).annotatedWith(Names.named(LexerIdeBindings.CONTENT_ASSIST)).to(InternalXRobotDSLLexer)
	}

	def Class<? extends IContentAssistParser> bindIContentAssistParser() {
		XRobotDSLParser
	}
	
	def Class<? extends IServerResourceHandler> bindIServerResourceHandler() {
		FileResourceHandler
	}
	
	def Class<? extends IResourceBaseProvider> bindIResourceBaseProvider() {
		XRobotsResourceBaseProvider
	}

}
