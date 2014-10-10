package org.xtext.xrobot.api

/**
 * Specification of the geometry of robots.
 */
interface IRobotGeometry {
	
	/**
	 * The total length of the robot in centimeters including its scoop.
	 * Value is 25cm.
	 */
	val ROBOT_LENGTH = 25.0

	/**
	 * The total width of the robot in centimeters.
	 * Value is 12cm.
	 */
	val ROBOT_WIDTH = 12.0
	
	/**
	 * The total height of the robot in centimeters.
	 * Value is 23.7cm.
	 */
	val ROBOT_HEIGHT = 23.7
	
	/**
	 * The diameter of the robot's wheels in centimeters.
	 * Value is 4.32cm.
	 */
	val ROBOT_WHEEL_DIAMETER = 4.32

	/**
	 * The robot's track width (distance of wheels) in centimeters.
	 * Value is 9.5cm.
	 */
	val ROBOT_WHEEL_DISTANCE = 9.5
	
	/**
	 * The distance in centimeters between the robot's axis and the fiducial marker.
	 * Value is 5cm.
	 */
	val ROBOT_MARKER_OFFSET = 5.0
	
	/**
	 * The distance in centimeters between the robot's axis and the back of the robot.
	 * Value is 4.5cm.
	 */
	val ROBOT_AXIS_OFFSET = 4.5
	
}