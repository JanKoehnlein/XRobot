package org.xtext.xrobot.api

import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.RobotID

import static org.xtext.xrobot.api.GeometryExtensions.*

import static extension java.lang.Math.*

/**
 * A position in Cartesian coordinates.
 * Coordinates are relative to the center of the arena in centimeters.
 */
@Data
class Position {
	double x
	double y
	
	/**
	 * @return the {@link Direction} to this from the center of the arena.
	 */
	def toDirection() {
		new Direction(sqrt(x*x+y*y), atan2(y, x).toDegrees)
	}
	
	def +(Position p) {
		new Position(x + p.x, y + p.y)
	}
	
	def -(Position p) {
		new Position(x - p.x, y - p.y)
	}
	
	def -() {
		new Position(-x, -y)
	}
	
	def *(double scalar) {
		new Position(x*scalar, y*scalar)
	}
}

/**
 * A direction in polar coordinates.
 * The angle is in degrees and the distance is in centimeters. 
 */
@Data
class Direction {
	double distance
	double angle
	
	/**
	 * @return the {@link Position} of the point in this direction from the center of the arena.
	 */
	def toPosition() {
		new Position(distance * cos(angle.toRadians), distance * sin(angle.toRadians));
	}
	
	def *(double scalar) {
		new Direction(distance*scalar, angle)
	}
}

/** 
 * The position of a robot, including its viewDirection in degrees (0 is the x-axis)
 */
@Data
class RobotPosition extends Position {
	RobotID robotID
	double viewDirection
	
	/**
	 * @return the direction to the given <code>position</code> taking the {@link viewDirection} 
	 * into account. 
	 */
	def getRelativeDirection(Position position) {
		val absDirection = (position - this).toDirection
		new Direction(absDirection.distance, normalizeAngle(absDirection.angle - viewDirection))
	}
}

class GeometryExtensions {
	static def *(double scalar, Position p) {
		p * scalar
	}

	static def *(double scalar, Direction d) {
		d * scalar
	}
	
	static def normalizeAngle(double angle) {
		var result = angle
		while(result > 180)
			result -= 360
		while(result <= -180) 
			result += 360
		result			
	}
}
