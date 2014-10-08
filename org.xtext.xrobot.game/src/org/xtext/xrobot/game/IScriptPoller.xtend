package org.xtext.xrobot.game

interface IScriptPoller {
	
	def void start(GameServer gameServer)
	
	def void stop()
	
}