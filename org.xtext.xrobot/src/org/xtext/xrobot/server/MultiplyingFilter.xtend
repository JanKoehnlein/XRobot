package org.xtext.xrobot.server

import org.xtext.xrobot.OpponentPosition
import org.xtext.xrobot.api.RobotSight

/**
 * A filter that combines new samples with the current values using factors.
 */
class MultiplyingFilter implements IRobotSightFilter {
	
	/** The default factor to apply to the last computed distance value. */
	static val DISTANCE_FACTOR = 0.8
	/** The maximal difference of a distance sample to the last computed distance. */
	static val MAX_DISTANCE_DIFF = 10.0
	/** The default factor to apply to the last computed angle value. */
	static val ANGLE_FACTOR = 0.7
	/** The maximal difference of an angle sample to the last computed angle. */
	static val MAX_ANGLE_DIFF = 10.0
	/** The minimal factor for reusing the last computed value. */
	static val MIN_VALID_FACTOR = 0.08
	
	var lastDistance = 0.0
	var lastDistanceFactor = 0.0
	var lastAngle = 0.0
	var lastAngleFactor = 0.0

	override RobotSight apply(OpponentPosition opponentPosition) {
		var distance = lastDistance
		var validDistance = false
		var angle = lastAngle
		var validAngle = false
		if (opponentPosition.detected) {
			val newDistance = opponentPosition.distanceInCentimeters
			if (lastDistanceFactor < MIN_VALID_FACTOR
					|| Math.abs(newDistance - lastDistance) <= MAX_DISTANCE_DIFF) {
				// We measured a valid distance sample
				distance = newDistance
				validDistance = true
				val newAngle = opponentPosition.angleInDegrees
				if (lastAngleFactor < MIN_VALID_FACTOR
						|| Math.abs(newAngle - lastAngle) <= MAX_ANGLE_DIFF) {
					// We measured a valid angle sample
					angle = newAngle
					validAngle = true
				}
			}
		}
		
		if (validDistance) {
			// Compute the distance as a combination of the last value and the current sample
			distance = lastDistanceFactor * lastDistance + (1 - lastDistanceFactor) * distance
			// Reset the distance factor
			lastDistanceFactor = DISTANCE_FACTOR
			lastDistance = distance
		} else {
			// Decrease the weight of the last distance value
			lastDistanceFactor *= DISTANCE_FACTOR
			if (lastDistanceFactor >= MIN_VALID_FACTOR) {
				validDistance = true
			}
		}
		
		if (validAngle) {
			// Compute the angle as a combination of the last value and the current sample
			angle = lastAngleFactor * lastAngle + (1 - lastAngleFactor) * angle
			// Reset the angle factor
			lastAngleFactor = ANGLE_FACTOR
			lastAngle = angle
		} else {
			// Decrease the weight of the last angle value
			lastAngleFactor *= ANGLE_FACTOR
			if (lastAngleFactor >= MIN_VALID_FACTOR) {
				validAngle = true
			}
		}
		
		println(opponentPosition.distanceInCentimeters + ","
			+ opponentPosition.angleInDegrees + ","
			+ (if (validAngle && validDistance) 1 else 0) + ","
			+ distance + ","
			+ angle
		)
		new RobotSight(angle, distance, validAngle && validDistance)
	}
	
}
