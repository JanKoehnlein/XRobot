package org.xtext.xrobot.dsl.ui.contentassist

import com.google.inject.Inject
import org.eclipse.jface.text.templates.ContextTypeRegistry
import org.eclipse.jface.text.templates.Template
import org.eclipse.jface.text.templates.persistence.TemplateStore
import org.eclipse.xtext.ui.editor.templates.ContextTypeIdHelper
import org.eclipse.xtext.xbase.ui.templates.XbaseTemplateProposalProvider

class XRobotTemplateProposalProvider extends XbaseTemplateProposalProvider {

	static val TEMPLATE_RELEVANCE = #{'mode'->1000, 'field'->900, 'sub'->800}
	
	@Inject
	new(TemplateStore templateStore, ContextTypeRegistry registry, ContextTypeIdHelper helper) {
		super(templateStore, registry, helper)
	}
	
	override getRelevance(Template template) {
		val relevance = TEMPLATE_RELEVANCE.get(template.name)
		relevance ?: super.getRelevance(template)
	}
	
}