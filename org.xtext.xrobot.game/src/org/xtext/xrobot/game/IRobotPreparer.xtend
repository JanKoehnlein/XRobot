package org.xtext.xrobot.game

interface IRobotPreparer {
	
	def void setSlot(PlayerSlot slot)
	
	def void prepare()
	
	def void waitReady()
	
	def void cancel()
	
}