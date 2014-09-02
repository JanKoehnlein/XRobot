package org.xtext.xrobot.dsl.interpreter

import org.xtext.xrobot.dsl.xRobotDSL.Mode

interface IRobotListener {
	
	def void modeChanged(Mode newMode)
	
	def void lineChanged(int line)
	
}