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
import org.xtext.xrobot.dsl.services.XRobotDSLGrammarAccess
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage

import static extension org.eclipse.xtext.EcoreUtil2.*
import org.xtext.xrobot.dsl.xRobotDSL.Field
import org.eclipse.xtext.xbase.ui.highlighting.XbaseHighlightingConfiguration

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
		if(object instanceof Field) 
			highlightFeature(acceptor, object, XRobotDSLPackage.Literals.FIELD__NAME, XbaseHighlightingConfiguration.FIELD)
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