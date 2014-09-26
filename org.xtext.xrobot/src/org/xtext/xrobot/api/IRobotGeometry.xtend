package org.xtext.xrobot.api

interface IRobotGeometry {
	/**
	 * The length of the robot in centimeters including its scoop.
	 */
	val LENGTH = 25.0

	/**
	 * The width of the robot in centimeters.
	 */
	val WIDTH = 12.0
	
	/**
	 * The height of the robot in centimeters.
	 */
	val HEIGHT = 23.7
	
	/**
	 * The diameter of the robot's wheels in centimeters.
	 */
	val WHEEL_DIAMETER = 4.32

	/**
	 * The robot's track width in centimeters.
	 */
	val WHEEL_DISTANCE = 9.5
	
	/**
	 * The distance in centimeters between the robot's axis and its reported position.
	 * The reported position is slightly ahead of the axis, hence when the robot rotates
	 * its reported position is also affected.
	 */
	val POSITION_OFFSET = 5.0
	
}