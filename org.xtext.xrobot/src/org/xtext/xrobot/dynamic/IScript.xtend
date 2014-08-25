package org.xtext.xrobot.dynamic

import org.xtext.xrobot.api.IRobot

interface IScript {
	def void run(IRobot robot)
}