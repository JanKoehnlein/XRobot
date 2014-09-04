package org.xtext.xrobot.api

import org.eclipse.xtend.lib.annotations.Data

/**
 * The robot's infrared sight used to detect the opponent.
 */
@Data
class RobotSight {
	double angle
	double distance
	boolean detected
}