package org.xtext.xrobot.server

import org.xtext.xrobot.api.RobotSight
import org.xtext.xrobot.OpponentPosition

/**
 * A filter on the data received from the infrared sensor for improving accuracy.
 */
interface IRobotSightFilter {
	
	def RobotSight apply(OpponentPosition opponentPosition)
	
}