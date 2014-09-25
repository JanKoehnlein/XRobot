package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.camera.CameraSample

interface IRemoteRobot extends IRobot {
	
	interface Connector {
		def Factory getRobotFactory(RobotID robotID)
	}

	interface Factory {
		def RobotID getRobotID()

		def void release()

		def void reset()

		def boolean isAlive()

		def IRemoteRobot newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException

		def IRemoteRobot newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot)
	}
	
	def void waitForUpdate(int timeout) throws SocketTimeoutException
	
	def void release()
	
	def RobotServerState getState()
	
	def double getBatteryState()
	
	def CameraSample getCameraSample()
}
