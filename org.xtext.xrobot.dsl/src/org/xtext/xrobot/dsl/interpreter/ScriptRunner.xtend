/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.concurrent.CopyOnWriteArrayList
import org.apache.log4j.Logger
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot

class ScriptRunner {

	static val LOG = Logger.getLogger(ScriptRunner)

	@Inject Provider<XRobotInterpreter> interpreterProvider
	
	val listeners = new CopyOnWriteArrayList<IRobotListener>
	
	def addRobotListener(IRobotListener listener) {
		listeners += listener
	}
	
	def void run(Program program, IRemoteRobot.Factory robotFactory, CancelIndicator cancelIndicator) {
		if(program != null && robotFactory != null) {
			try {
				interpreterProvider.get.execute(program, robotFactory, listeners, cancelIndicator)
			} catch (CanceledException exc) {
				LOG.info('Canceled')
			}
		}
	}
}
