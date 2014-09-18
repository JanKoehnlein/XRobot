package org.xtext.xrobot.api

interface IRobotGeometry {
	/**
	 * The length of the robot in centimeters including its scoop.
	 */
	val LENGHT = 24

	/**
	 * The width of the robot in centimeters.
	 */
	val WIDTH = 12
	
	/**
	 * The diameter of the robot's wheels in centimeters.
	 */
	val WHEEL_DIAMETER = 4.32

	/**
	 * The robot's track width in centimeters.
	 */
	val WHEEL_DISTANCE = 9.5
}