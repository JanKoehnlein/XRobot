package org.xtext.xrobot.server

import org.xtext.xrobot.OpponentPosition
import org.xtext.xrobot.api.RobotSight

/**
 * A filter that combines new samples with the current values using factors.
 */
class MultiplyingFilter implements IRobotSightFilter {
	
	/** The default factor to apply to the last computed distance value. */
	static val DISTANCE_FACTOR = 0.85
	/** The default factor to apply to the last computed angle value. */
	static val ANGLE_FACTOR = 0.7
	/** The minimal factor for reusing the last computed value. */
	static val MIN_VALID_FACTOR = 0.08
	
	var lastDistance = 0.0
	var lastDistanceFactor = 0.0
	var lastAngle = 0.0
	var lastAngleFactor = 0.0

	override RobotSight apply(OpponentPosition opponentPosition) {
		var double distance
		var double angle
		var validPosition = false
		if (opponentPosition.detected) {
			// Compute the distance as a combination of the last value and the current sample
			val newDistance = opponentPosition.distanceInCentimeters
			distance = lastDistanceFactor * lastDistance + (1 - lastDistanceFactor) * newDistance
			// Reset the distance factor
			lastDistanceFactor = DISTANCE_FACTOR
			lastDistance = distance

			// Compute the angle as a combination of the last value and the current sample
			val newAngle = opponentPosition.angleInDegrees
			angle = lastAngleFactor * lastAngle + (1 - lastAngleFactor) * newAngle
			// Reset the angle factor
			lastAngleFactor = ANGLE_FACTOR
			lastAngle = angle
			
			validPosition = true
		} else {
			// Decrease the weight of the last computed values
			lastDistanceFactor *= DISTANCE_FACTOR
			lastAngleFactor *= ANGLE_FACTOR
			if (lastDistanceFactor >= MIN_VALID_FACTOR && lastAngleFactor >= MIN_VALID_FACTOR) {
				distance = lastDistance
				angle = lastAngle
				validPosition = true
			}
		}
		
		new RobotSight(angle, distance, validPosition)
	}
	
}
