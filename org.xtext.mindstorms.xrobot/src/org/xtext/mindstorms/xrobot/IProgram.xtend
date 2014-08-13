package org.xtext.mindstorms.xrobot

interface IProgram {
	
	def void run(IRobot robot)
	
	def boolean addSubProgram(ISubProgram sub)
}