package org.xtext.mindstorms.xrobot.dynamic

import org.xtext.mindstorms.xrobot.api.IRobot

interface IScript {
	def void run(IRobot robot)
}