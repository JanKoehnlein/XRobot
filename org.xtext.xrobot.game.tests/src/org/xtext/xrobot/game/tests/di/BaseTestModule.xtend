/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import com.google.inject.Binder
import com.google.inject.Module
import org.xtext.xrobot.game.IRobotPreparer
import org.xtext.xrobot.game.IScriptPoller
import org.xtext.xrobot.server.IRemoteRobot

class BaseTestModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IRemoteRobot.Connector).to(MockRobotConnector)
		binder.bind(IScriptPoller).to(MockScriptPoller)
		binder.bind(IRobotPreparer).to(MockRobotPreparer)
	}
	
}