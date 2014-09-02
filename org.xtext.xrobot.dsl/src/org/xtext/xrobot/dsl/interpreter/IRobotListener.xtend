package org.xtext.xrobot.dsl.interpreter

import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.server.IRobotState

interface IRobotListener {
	
	def void modeChanged(Mode newMode)
	
	def void stateChanged(IRobotState newState)	

	def void lineChanged(int line)
	
}