package org.xtext.mindstorms.xrobot

import org.xtext.mindstorms.xrobot.api.IRobot

interface ISubProgram {
	
	def String getName()
	
	def boolean checkCondition(IRobot robot)
	
	def int getPriority()
	
	def void run(IRobot robot)
	
	def void stop(IRobot robot)
	
}