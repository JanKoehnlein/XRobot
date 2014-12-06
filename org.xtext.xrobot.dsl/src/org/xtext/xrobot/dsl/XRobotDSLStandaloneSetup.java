/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class XRobotDSLStandaloneSetup extends XRobotDSLStandaloneSetupGenerated{

	public static void doSetup() {
		new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

