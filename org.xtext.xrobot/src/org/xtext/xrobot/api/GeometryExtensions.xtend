package org.xtext.xrobot.api

/**
 * Helper functions for {@link Vector}s. These are automatically imported as extension methods.
 */
class GeometryExtensions {
	
	/**
	 * Return a new {@link Vector} with the coordinates of {@code v} multiplied 
	 * with the given <code>scalar</code>.
	 * 
	 * @param scalar
	 * 		the factor to multiply the coordinates with
	 * @param v
	 * 		a vector
	 * @return a new vector with the coordinates of {@code v} multiplied 
	 *    with the given <code>scalar</code>
	 */
	static def *(double scalar, Vector v) {
		v * scalar
	}
	
	/**
	 * Return the <code>angle</code> minimized to be in the range from -180&deg; to 180&deg;.
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
