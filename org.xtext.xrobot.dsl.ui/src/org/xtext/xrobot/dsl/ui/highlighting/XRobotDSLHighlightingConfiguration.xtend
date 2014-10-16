package org.xtext.xrobot.dsl.ui.highlighting

import org.eclipse.swt.SWT
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfigurationAcceptor
import org.eclipse.xtext.xbase.ui.highlighting.XbaseHighlightingConfiguration

class XRobotDSLHighlightingConfiguration extends XbaseHighlightingConfiguration {
	
	public static val MODE_NAME = 'XRobotDSL.MODE_NAME'
	
	override configure(IHighlightingConfigurationAcceptor acceptor) {
		super.configure(acceptor)
		acceptor.acceptDefaultHighlighting(MODE_NAME, 'Mode name', modeNameTextStyle)
	}
	
	def modeNameTextStyle() {
		defaultTextStyle.copy => [
			style = SWT.BOLD
		]
	}
	
}