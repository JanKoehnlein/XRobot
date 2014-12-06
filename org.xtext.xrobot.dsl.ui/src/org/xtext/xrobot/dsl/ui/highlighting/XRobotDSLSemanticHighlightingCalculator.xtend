/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.ui.highlighting

import com.google.inject.Inject
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.TerminalRule
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightedPositionAcceptor
import org.eclipse.xtext.xbase.ui.highlighting.XbaseHighlightingCalculator
import org.eclipse.xtext.xbase.ui.highlighting.XbaseHighlightingConfiguration
import org.xtext.xrobot.dsl.services.XRobotDSLGrammarAccess
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Variable
import org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage

import static extension org.eclipse.xtext.EcoreUtil2.*

class XRobotDSLSemanticHighlightingCalculator extends XbaseHighlightingCalculator {
	
	Set<Keyword> contextualKeywords
	
	@Inject
	protected def setXtendGrammarAccess(extension XRobotDSLGrammarAccess grammarAccess) {
		contextualKeywords = (validIDRule.getAllContentsOfType(Keyword)
			+ featureCallIDRule.getAllContentsOfType(Keyword)) .toSet
	}

	override protected highlightElement(EObject object, IHighlightedPositionAcceptor acceptor) {
		if(object instanceof Mode) 
			highlightFeature(acceptor, object, XRobotDSLPackage.Literals.MODE__NAME, XRobotDSLHighlightingConfiguration.MODE_NAME)
		if(object instanceof Variable) 
			highlightFeature(acceptor, object, XRobotDSLPackage.Literals.VARIABLE__NAME, XbaseHighlightingConfiguration.FIELD)
		super.highlightElement(object, acceptor)
	}
	
	override protected void highlightSpecialIdentifiers(ILeafNode leafNode, IHighlightedPositionAcceptor acceptor,
			TerminalRule idRule) {
		super.highlightSpecialIdentifiers(leafNode, acceptor, idRule);
		if (contextualKeywords != null && contextualKeywords.contains(leafNode.getGrammarElement())) {
			val leafRegion = leafNode.getTextRegion();
			acceptor.addPosition(leafRegion.getOffset(), leafRegion.getLength(),
					DefaultHighlightingConfiguration.DEFAULT_ID);
		}
	}
}