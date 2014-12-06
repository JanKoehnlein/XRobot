/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.server

import com.google.inject.ImplementedBy
import java.net.SocketTimeoutException
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.camera.CameraTimeoutException

interface IRemoteRobot extends IRobot {
	
	@ImplementedBy(RemoteRobotConnector)
	interface Connector {
		def Factory getRobotFactory(RobotID robotID)
	}

	interface Factory {
		def RobotID getRobotID()

		def void release()

		def void reset()

		def boolean isAlive()
		
		def IRemoteRobot newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException, CameraTimeoutException

		def IRemoteRobot newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot)
		
		def IRemoteRobot getLastRobot()
	}
	
	def void waitForUpdate(int timeout) throws SocketTimeoutException, CameraTimeoutException
	
	def void release()
	
	def void reset()
	
	def double getBatteryState()
	
	def RobotID getRobotID()
	
	def boolean isDead()
	
	def void setInvincible(boolean invincible)
	
	def void calibrateScoop()
	
}
