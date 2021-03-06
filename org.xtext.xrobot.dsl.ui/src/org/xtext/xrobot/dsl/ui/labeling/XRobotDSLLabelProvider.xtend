/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.jface.resource.ImageDescriptor
import org.eclipse.xtext.xbase.ui.labeling.XbaseImages2
import org.eclipse.xtext.xbase.ui.labeling.XbaseLabelProvider
import org.xtext.xrobot.dsl.xRobotDSL.Function
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Variable

import static org.eclipse.xtext.common.types.JvmVisibility.*

/**
 * Provides labels for a EObjects.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#labelProvider
 */
class XRobotDSLLabelProvider extends XbaseLabelProvider {

	@Inject XbaseImages2 images 
	
	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	protected def dispatch ImageDescriptor imageDescriptor(Mode mode) {
		images.forOperation(DEFAULT, 0)
	}

	protected def dispatch ImageDescriptor imageDescriptor(Function function) {
		images.forOperation(PUBLIC, 0)
	}

	protected def dispatch ImageDescriptor imageDescriptor(Variable variable) {
		images.forField(PRIVATE, 0)
	}

}
