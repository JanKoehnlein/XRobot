package org.xtext.xrobot.api

/**
 * Specification of the geometry of robots.
 */
interface IRobotGeometry {
	
	/**
	 * The total length of the robot in centimeters including its scoop.
	 */
	val LENGTH = 25.0

	/**
	 * The total width of the robot in centimeters.
	 */
	val WIDTH = 12.0
	
	/**
	 * The total height of the robot in centimeters.
	 */
	val HEIGHT = 23.7
	
	/**
	 * The diameter of the robot's wheels in centimeters.
	 */
	val WHEEL_DIAMETER = 4.32

	/**
	 * The robot's track width (distance of wheels) in centimeters.
	 */
	val WHEEL_DISTANCE = 9.5
	
	/**
	 * The distance in centimeters between the robot's axis and the fiducial marker.
	 */
	val MARKER_OFFSET = 5.0
	
	/**
	 * The distance in centimeters between the robot's axis and the back of the robot.
	 */
	val AXIS_OFFSET = 4.5
	
}