/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.ui.contentassist

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.typesystem.IExpressionScope
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program

/**
 * see http://www.eclipse.org/Xtext/documentation.html#contentAssist on how to customize content assistant
 */
class XRobotDSLProposalProvider extends AbstractXRobotDSLProposalProvider {
	
	override completeMode_Condition(EObject model, Assignment assignment, ContentAssistContext context, ICompletionProposalAcceptor acceptor) {
		if (model instanceof Mode) {
			createLocalVariableAndImplicitProposals(model.action, IExpressionScope.Anchor.BEFORE, context, acceptor);
		} else if (model instanceof Program && context.previousModel instanceof XExpression && context.prefix.length > 0) {
			createLocalVariableAndImplicitProposals(context.previousModel, IExpressionScope.Anchor.BEFORE, context, acceptor);
		}
	}
}
