package org.xtext.xrobot.dsl.web

import com.google.inject.Binder
import com.google.inject.name.Names
import java.util.concurrent.ExecutorService
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ide.LexerIdeBindings
import org.eclipse.xtext.ide.editor.contentassist.antlr.IContentAssistParser
import org.eclipse.xtext.ide.editor.contentassist.antlr.internal.Lexer
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

}
