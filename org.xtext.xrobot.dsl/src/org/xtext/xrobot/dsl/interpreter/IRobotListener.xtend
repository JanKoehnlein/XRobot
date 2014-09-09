package org.xtext.xrobot.dsl.interpreter

import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.server.RemoteRobot

interface IRobotListener {
	
	def void modeChanged(Mode newMode)
	
	def void stateChanged(RemoteRobot robot)
	
	def void variableChanged(String name, Object value)

	def void lineChanged(int line)
	
}