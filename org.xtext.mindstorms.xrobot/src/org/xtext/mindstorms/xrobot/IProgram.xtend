package org.xtext.mindstorms.xrobot

import org.xtext.mindstorms.xrobot.api.IRobot

interface IProgram {
	
	def void run(IRobot robot)
	
	def boolean addSubProgram(ISubProgram sub)
}