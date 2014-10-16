package org.xtext.xrobot.api

import org.eclipse.xtend.lib.annotations.Data

/** 
 * The position of a robot, including its Cartesian coordinates {@code x} and {@code y},
 * the actual speed, the view direction, and the actual rotation speed. The coordinates
 * can be converted to a {@link Vector} using {@link #toVector()}.
 * 
 * <p>The coordinates are in centimeters relative to the center of the arena.
 * The reference point is the center of the robot's axis.
 * As opposed to screen coordinates, robots use a right-handed coordinate system,
 * i.e. the vertical axis points upward. The speed is given as a {@link Vector} in this
 * coordinate system with the unit centimeters per second. The view direction is given
 * in degrees in the range between -180&deg; to 180&deg;. The angle is interpreted
 * mathematically, that means a vector with angle 0 points to the right and increasing
 * the angle corresponds to a counter-clockwise rotation. The rotation speed is in
 * degrees per second.
 */
@Data
class RobotPosition {
	
	/**
	 * The horizontal coordinate in centimeters, relative to the center of the arena.
	 * The reference point is the center of the robot's axis.
	 */
	double x
	
	/**
	 * The vertical coordinate in centimeters, relative to the center of the arena.
	 * The reference point is the center of the robot's axis.
	 */
	double y
	
	/**
	 * The actual speed as a vector, which gives you horizontal and vertical speed
	 * (in centimeters per second), the combined speed value, and the angle to the
	 * motion direction (in degrees).
	 * 
	 * <p>Note that the speed value {@code actualSpeed.length} may be different from
	 * what you would expect after setting a driving speed for the robot, and even
	 * the angle of the speed vector may be different from the robot's view direction.
	 * There are multiple possible reasons for this:
	 * <ul>
	 *   <li>The robot is not able to reach your requested driving speed.</li>
	 *   <li>Your opponent is in the way so you cannot move freely.</li>
	 *   <li>Your opponent is pushing you.</li>
	 *   <li>Measurement inaccuracies.</li>
	 * </ul></p>
	 */
	Vector actualSpeed;
	
	/**
	 * The direction in degrees in which the robot is heading. It is given in the range
	 * between -180&deg; to 180&deg;. The angle is interpreted mathematically, that means
	 * a vector with angle 0 points to the right and increasing the angle corresponds to a
	 * counter-clockwise rotation.
	 */
	double viewDirection
	
	/**
	 * The actual rotation speed in degrees per second. A positive rotation speed corresponds
	 * to a counter-clockwise rotation.
	 * 
	 * <p>Note that the rotation speed may be different from what you would expect after
	 * setting a rotation speed for the robot. There are multiple possible reasons for this:
	 * <ul>
	 *   <li>The robot is not able to reach your requested rotation speed.</li>
	 *   <li>Your opponent is in the way so you cannot move freely.</li>
	 *   <li>Your opponent is pushing you.</li>
	 *   <li>Measurement inaccuracies.</li>
	 * </ul></p>
	 */
	double actualRotationSpeed
	
	/**
	 * Create a vector from the {@code x} and {@code y} coordinates of the robot position.
	 * The length of this vector corresponds to the distance of the robot's axis from the center
	 * of the arena.
	 * 
	 * @return a vector corresponding to the absolute position of the robot
	 */
	def toVector() {
		Vector.cartesian(x, y)
	}
	
	/**
	 * Return the bearing to the given <code>position</code> taking the {@link #viewDirection} 
	 * into account. This means that the given position vector is translated into the
	 * local coordinate system of this robot. If the given position is directly in front of
	 * this robot, the resulting vector has an angle of 0.
	 * 
	 * @param position
	 * 		a position to use as reference point
	 * @return a vector to the given <code>position</code> from the perspective of this robot
	 */
	def getRelativePosition(Vector position) {
		val absBearing = position - this.toVector
		Vector.polar(absBearing.length, absBearing.angle - viewDirection)
	}
	
	/**
	 * Return the relative speed taking the {@link #viewDirection} into account. For example,
	 * given a {@link RobotPosition} instance {@code p},
	 * <pre> p.relativeSpeed(p.actualSpeed) </pre>
	 * yields the robot's own speed relative to its orientation. If this resulting speed vector
	 * has an angle of 90&deg; it means that the robot is moving sideways to the left,
	 * so probably the opponent robot is pushing it from the right side.
	 * 
	 * @param speed
	 * 		a speed vector
	 * @param the corresponding speed vector from the perspective of this robot
	 */
	def getRelativeSpeed(Vector speed) {
		Vector.polar(speed.length, speed.angle - viewDirection)
	}
	
}