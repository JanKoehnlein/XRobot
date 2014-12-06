/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import com.google.inject.Binder
import com.google.inject.Module
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobotConnector
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ui.GameControlWindow

class XRobotModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IRemoteRobot.Connector).to(RemoteRobotConnector)
		binder.bind(IScriptPoller).to(ScriptPoller)
		binder.bind(IRobotPreparer).to(RobotPreparer)
		binder.bind(IErrorReporter).to(Display)
		binder.bind(IGameListener).to(GameControlWindow)
		binder.bind(ITimeListener).to(Display)
	}
	
}