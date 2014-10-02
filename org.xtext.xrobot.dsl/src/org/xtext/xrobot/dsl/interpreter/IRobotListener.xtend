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