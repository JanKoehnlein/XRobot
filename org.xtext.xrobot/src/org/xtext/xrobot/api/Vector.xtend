package org.xtext.xrobot.api

import static org.eclipse.xtext.xbase.lib.IntegerExtensions.*
import static org.xtext.xrobot.api.GeometryExtensions.*

import static extension java.lang.Math.*

/**
 * A vector in a two-dimensional space. Vectors can be defined with Cartesian coordinates
 * {@code x} and {@code y} or with polar coordinates {@code length} and {@code angle}.
 * There is a static construction method for each of these definitions. Regardless of how
 * a vector has been defined, all four values are always available.
 * For example, the expression
 * <pre>Vector.cartesian(10, 10).getAngle()</pre>
 * yields the value 45&deg;, and
 * <pre>Vector.polar(10, 180).getX()</pre>
 * yields the value -10.
 * 
 * <p>Cartesian coordinates ({@code x}, {@code y}) as well as the {@code length} are in
 * centimeters (for positions) or in centimeters per second (for speeds),
 * while the {@code angle} is in degrees. Angles are always normalized to the
 * range from -180&deg; to +180&deg; using {@link GeometryExtensions#minimizeAngle(double)}.</p>
 */
class Vector {
	
	/** The horizontal coordinate in centimeters. */
	double x

	/** The vertical coordinate in centimeters. */
	double y
	
	/** The length in centimeters. */
	double length
	
	/** The angle in degrees. Ranges from -180&deg; to 180&deg;. */
	double angle
	
	/** Whether the Cartesian coordinates are already defined. */
	boolean cartesianDefined = false
	
	/** Whether the polar coordinates are already defined. */
	boolean polarDefined = false
	
	/**
	 * Hide the constructor to avoid instantiation from outside this class.
	 */
	private new() {}
	
	/**
	 * Create a vector defined with Cartesian coordinates. The corresponding polar coordinates
	 * are computed on demand.
	 * 
	 * @param x
	 * 		The horizontal coordinate in centimeters
	 * @param y
	 * 		The vertical coordinate in centimeters
	 * @return a new vector defined with Cartesian coordinates.
	 */
	static def Vector cartesian(double x, double y) {
		val v = new Vector()
		v.x = x
		v.y = y
		v.cartesianDefined = true
		return v
	}
	
	/**
	 * Create a vector defined with polar coordinates. The corresponding Cartesian coordinates
	 * are computed on demand.
	 * 
	 * @param length
	 * 		The length in centimeters (must not be negative)
	 * @param angle
	 * 		The angle in degrees (this is normalized to the range from -180&deg; to +180&deg;)
	 * @return a new vector defined with polar coordinates
	 */
	static def Vector polar(double length, double angle) {
		if (length < 0) {
			throw new IllegalArgumentException("The length of a vector must not be negative.")
		}
		val v = new Vector()
		v.length = length
		v.angle = minimizeAngle(angle)
		v.polarDefined = true
		return v
	}

	/**
	 * Create a zero vector. The coordinates and length are all set to 0.
	 * 
	 * @return a new vector with zero length 
	 */	
	static def Vector zero() {
		val v = new Vector()
		v.cartesianDefined = true
		v.polarDefined = true
		return v
	}
	
	override toString() {
		if (cartesianDefined) {
			'(x=' + x + ', y=' + y + ')'
		} else {
			'(l=' + length + ', a=' + angle + ')'
		}
	}
	
	override equals(Object obj) {
		if (obj instanceof Vector) {
			val other = obj as Vector
			this.getX == other.getX && this.getY == other.getY
		}
		false
	}
	
	override hashCode() {
		 bitwiseXor(getX.hashCode, getY.hashCode)
	}
	
	/**
	 * Check whether the Cartesian coordinates are already defined, and compute them if necessary.
	 */
	private def checkCartesian() {
		if (!cartesianDefined) {
			x = length * cos(angle.toRadians)
			y = length * sin(angle.toRadians)
			cartesianDefined = true
		}
	}
	
	/**
	 * Return the horizontal coordinate in centimeters (for positions) or centimeters per
	 * second (for speeds).
	 * 
	 * @return the horizontal coordinate
	 */
	def getX() {
		checkCartesian()
		return x
	}
	
	/**
	 * Return the vertical coordinate in centimeters (for positions) or centimeters per
	 * second (for speeds).
	 * 
	 * @return the vertical coordinate
	 */
	def getY() {
		checkCartesian()
		return y
	}
	
	/**
	 * Check whether the polar coordinates are already defined, and compute them if necessary.
	 */
	private def checkPolar() {
		if (!polarDefined) {
			length = sqrt(x*x+y*y)
			if (length == 0.0)
				angle = 0.0
			else
				angle = atan2(y, x).toDegrees
			polarDefined = true
		}
	}
	
	/**
	 * Return the length of the vector in centimeters (for positions) or centimeters per
	 * second (for speeds). The meaning of this value depends on how the vector is used:
	 * <ul>
	 *   <li>If this represents an absolute position, the length corresponds to the distance
	 *     to the center of the arena.</li>
	 *   <li>If this represents a relative position, the length corresponds to the distance
	 *     between the two compared points.</li>
	 *   <li>If this represents a speed, the length corresponds to the absolute speed value.</li>
	 * </ul>
	 * 
	 * @return the length of this vector
	 */
	def getLength() {
		checkPolar()
		return length
	}
	
	/**
	 * Return the angle of the vector in degrees in the range from -180&deg; to +180&deg;.
	 * The angle is interpreted mathematically, that means a vector with angle 0 points to
	 * the right and increasing the angle corresponds to a counter-clockwise rotation.
	 * 
	 * @return the angle of this vector in degrees
	 */
	def getAngle() {
		checkPolar()
		return angle
	}
	
	/**
	 * Create a new {@link Vector} with the added coordinates of this and {@code v}.
	 * 
	 * @param v
	 * 		the vector to be added
	 * @return a new vector with the added coordinates of this and {@code v}
	 */
	def +(Vector v) {
		cartesian(this.getX + v.getX, this.getY + v.getY)
	}
	
	/**
	 * Create a new {@link Vector} with the coordinates of this minus the coordinates
	 * of {@code v}.
	 * 
	 * @param v
	 * 		the vector to be subtracted
	 * @return a new vector with the coordinates of this minus the coordinates of {@code v}
	 */
	def -(Vector v) {
		cartesian(this.getX - v.getX, this.getY - v.getY)
	}
	
	/**
	 * Create a new {@link Vector} with the coordinates of this negated, that is the
	 * additive inverse of this vector.
	 * 
	 * @return a new vector with negated coordinates
	 */
	def -() {
		if (cartesianDefined) {
			cartesian(-x, -y)
		} else {
			polar(length, angle + 180)
		}
	}
	
	/**
	 * Create a new {@link Vector} with the coordinates of this multiplied with the given factor.
	 * 
	 * @param scalar
	 * 		the factor to multiply the coordinates with
	 * @return a new vector with the coordinates of this multiplied by the given {@code scalar}
	 */
	def *(double scalar) {
		if (cartesianDefined) {
			cartesian(x * scalar, y * scalar)
		} else if (scalar < 0) {
			polar(-length * scalar, angle + 180)
		} else {
			polar(length * scalar, angle)
		}
	}
	
	/**
	 * Create a new {@link Vector} with the coordinates of this divided by the given factor.
	 * 
	 * @param scalar
	 * 		the value to divide the coordinates by
	 * @return a new vector with the coordinates of this divided by the given {@code scalar}
	 */
	def /(double scalar) {
		if (cartesianDefined) {
			cartesian(x / scalar, y / scalar)
		} else {
			polar(length / scalar, angle)
		}
	}
	
	/**
	 * Create a new {@link Vector} with the coordinates of this rotated by the given angle.
	 * 
	 * @param rotationAngle
	 * 		the angle to rotate the coordinates by
	 * @return a new vector with the coordinates of this rotated by the given {@code rotationAngle}
	 */
	def rotate(double rotationAngle) {
		polar(getLength, getAngle + rotationAngle)
	}
	
}
