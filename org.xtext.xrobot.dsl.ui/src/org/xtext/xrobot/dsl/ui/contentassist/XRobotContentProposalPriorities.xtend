/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.ui.contentassist

import org.eclipse.jface.text.contentassist.ICompletionProposal
import org.eclipse.xtext.common.types.JvmExecutable
import org.eclipse.xtext.common.types.JvmField
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal
import org.eclipse.xtext.ui.editor.contentassist.ContentProposalPriorities
import org.eclipse.xtext.xbase.scoping.batch.IIdentifiableElementDescription
import org.eclipse.xtext.xbase.scoping.batch.SimpleIdentifiableElementDescription
import org.eclipse.xtext.xbase.scoping.batch.StaticFeatureDescriptionWithTypeLiteralReceiver
import org.eclipse.xtext.xbase.ui.contentassist.XbaseProposalProvider

class XRobotContentProposalPriorities extends ContentProposalPriorities {

	override adjustCrossReferencePriority(ICompletionProposal proposal, String prefix) {
		if (proposal instanceof ConfigurableCompletionProposal) {
			val desc = proposal.getAdditionalData(XbaseProposalProvider.DESCRIPTION_KEY)
			switch desc {
				SimpleIdentifiableElementDescription case proposal.replacementString != 'this' &&
					proposal.replacementString != 'super': {
					adjustPriority(proposal, prefix, 570)
					return;
				}
				StaticFeatureDescriptionWithTypeLiteralReceiver: {
					adjustPriority(proposal, prefix, 560)
				}
				IIdentifiableElementDescription: {
					switch feature : desc.elementOrProxy {
						JvmField: {
							if(feature.static)
								adjustPriority(proposal, prefix, 510)
							else
								adjustPriority(proposal, prefix, 550)
							return;
						}
						JvmExecutable: {
							if(feature.declaringType.qualifiedName == 'java.lang.Object')
								adjustPriority(proposal, prefix, 490)
							else if(feature.static) 
								adjustPriority(proposal, prefix, 500)
							else 
								adjustPriority(proposal, prefix, 520)
							return;
						}
					}
				}
			}
		}

	}

}
