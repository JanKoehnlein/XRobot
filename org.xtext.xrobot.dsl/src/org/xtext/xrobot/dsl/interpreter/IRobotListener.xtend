/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.interpreter

import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.server.IRemoteRobot

interface IRobotListener {
	
	def void stateRead(IRemoteRobot robot)
	
	def void modeChanged(IRemoteRobot robot, Mode newMode)
	
	def void stateChanged(IRemoteRobot robot)
	
	def void variableChanged(String name, Object value)

	def void lineChanged(int line)

}