package org.xtext.xrobot.api

import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.RobotID

import static org.xtext.xrobot.api.GeometryExtensions.*

import static extension java.lang.Math.*

/**
 * A position in Cartesian coordinates {@link #x} and {@link #y}.
 * 
 * Coordinates are relative to the center of the arena in centimeters.
 * As opposed to screen coordinates, this is using a right-handed coordinate
 * system.
 */
@Data
class Position {
	/**
	 * The x-coordinate in centimeters 
	 */
	double x

	/**
	 * The y-coordinate in centimeters 
	 */
	double y
	
	/**
	 * Returns the {@link Direction} to this from the center of the arena.
	 * 
	 * @return the {@link Direction} to this from the center of the arena.
	 */
	def toDirection() {
		new Direction(sqrt(x*x+y*y), atan2(y, x).toDegrees)
	}
	
	/**
	 * Returns a new {@link Position} with the added coordinates of this
	 * and <code>p</code>.
	 * 
	 * @param p the position to be added.
	 * @return a new {@link Position} with the added coordinates of this 
	 *   	and <code>p</code>.
	 */
	def +(Position p) {
		new Position(x + p.x, y + p.y)
	}
	
	/**
	 * Returns a new {@link Position} with the coordinates of this minus 
	 * the coordinates of <code>p</code>.
	 * 
	 * @param p the position to be subtracted.
	 * @return a new {@link Position} with the coordinates of 
	 * 	this minus the coordinates of <code>p</code>.
	 */
	def -(Position p) {
		new Position(x - p.x, y - p.y)
	}
	
	/**
	 * Returns a new {@link Position} with the coordinates of this negated.
	 * 
	 * @return a new {@link Position} with the coordinates of 
	 * 	this negated.
	 */
	def -() {
		new Position(-x, -y)
	}
	
	/**
	 * Returns a new {@link Position} with the coordinates of this multiplied 
	 * by the given factor.
	 * 
	 * @param scalar the factor to multiply the coordinates with.
	 * @return a new {@link Position} with the coordinates of this multiplied 
	 *    by the given <code>scalar</code>.
	 */
	def *(double scalar) {
		new Position(x*scalar, y*scalar)
	}
}

/**
 * A direction (relative position) in polar coordinates.
 * 
 * The distance is in centimeters. The angle in degrees and 
 * ranges from -180&deg; to 180&deg;.
 */
@Data
class Direction {
	/**
	 * The distance in centimeters. 
	 */
	double distance
	
	/**
	 * The angle in degrees. Ranges from -180&deg; to 180&deg;.
	 */
	double angle
	
	/**
	 * Returns the {@link Position} of the point in this direction from the center of the arena.
	 * 
	 * @return the {@link Position} of the point in this direction from the center of the arena.
	 */
	def toPosition() {
		new Position(distance * cos(angle.toRadians), distance * sin(angle.toRadians));
	}
	
	/**
	 * Returns a new {@link Direction} with the same angle as this and the distance multiplied 
	 *   by <code>scalar</code>.
	 * 
	 * @param scalar the scaling factor.
	 * @returns a new {@link Direction} with the same angle as this and the distance multiplied 
	 *   by <code>scalar</code>.
	 */
	def *(double scalar) {
		new Direction(distance*scalar, angle)
	}
}

/** 
 * The position of a robot, including its Cartesian coordinates {@link #x} and {@link #y} and 
 * its {@link viewDirection}.
 * 
 * The Coordinates are in centimeters relative to the center of the arena 
 * As opposed to screen coordinates, this is using a right-handed coordinate
 * system.
 *
 * The {@link viewDirection} in degrees is relative to the x-axis and ranges between 
 * -180&deg; to 180&deg;.
 */
@Data
class RobotPosition extends Position {
	RobotID robotID
	
	/**
	 * The direction in degrees in which the robot is heading. 
	 * 
	 * It is relative to the x-axis and ranges between -180&deg; to 180&deg;. A positive angle
	 * means the robot is looking into the positive y-direction
	 */
	double viewDirection
	
	/**
	 * Returns the direction to the given <code>position</code> taking the {@link #viewDirection} 
	 * into account. 
	 * 
	 * @param position the position to use as a reference point.
	 * @return the direction to the given <code>position</code> taking the {@link #viewDirection} 
	 * into account. 
	 */
	def getRelativeDirection(Position position) {
		val absDirection = (position - this).toDirection
		new Direction(absDirection.distance, minimizeAngle(absDirection.angle - viewDirection))
	}
}

/**
 * Helper functions for {@link Position}s and {@link Direction}s. These are automatically imported
 * as extension methods.
 */
class GeometryExtensions {
	/**
	 * Returns a new {@link Position} with the coordinates of this multiplied 
	 * by the given <code>scalar</code>.
	 * 
	 * @param scalar the factor to multiply the coordinates with.
	 * @return a new {@link Position} with the coordinates of this multiplied 
	 *    by the given <code>scalar</code>.
	 */
	static def *(double scalar, Position p) {
		p * scalar
	}

	/**
	 * Returns a new {@link Direction} with the same angle as this and the distance multiplied 
	 *   by <code>scalar</code>.
	 * 
	 * @param scalar the scaling factor.
	 * @returns a new {@link Direction} with the same angle as this and the distance multiplied 
	 *   by <code>scalar</code>.
	 */
	static def *(double scalar, Direction d) {
		d * scalar
	}
	
	/**
	 * Returns the <code>angle</code> minimized to be in the range from -180&deg; to 180&deg;.
	 * 
	 * Use to minimize movements, e.g. instead of rotating 300&deg; to the left you should
	 * rather move 60&deg; to the right.
	 */
	static def minimizeAngle(double angle) {
		var result = angle
		while(result > 180)
			result -= 360
		while(result <= -180) 
			result += 360
		result			
	}
}
