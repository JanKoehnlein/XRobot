package org.xtext.xrobot.server

import java.util.LinkedList
import org.xtext.xrobot.OpponentPosition
import org.xtext.xrobot.api.RobotSight

/**
 * A filter on the data received from the infrared sensor for improving accuracy.
 */
class AveragingFilter implements IRobotSightFilter {
	
	/** The number of samples used for averaging the distance. */
	static val DISTANCE_BUFFER_SIZE = 20
	/** The maximal difference of a distance sample to the average distance. */
	static val MAX_DISTANCE_DIFF = 10.0
	/** The number of samples used for averaging the angle. */
	static val ANGLE_BUFFER_SIZE = 15
	/** The maximal difference of an angle sample to the average angle. */
	static val MAX_ANGLE_DIFF = 10.0
	/** The minimal number of buffered samples for comparing a new sample with the average. */
	static val MIN_COMP_SAMPLES = 3
	/** The maximal number of missed samples in a row before the result is marked as invalid. */
	static val MAX_MISSED_SAMPLES = 10
	
	val distanceBuffer = new LinkedList<Double>
	val angleBuffer = new LinkedList<Double>
	
	var lastDistance = 0.0
	var missedDistances = 0
	var lastAngle = 0.0
	var missedAngles = 0

	override RobotSight apply(OpponentPosition opponentPosition) {
		var distance = lastDistance
		var validDistance = false
		var angle = lastAngle
		var validAngle = false
		if (opponentPosition.detected) {
			val newDistance = opponentPosition.distanceInCentimeters
			if (distanceBuffer.size < MIN_COMP_SAMPLES
					|| Math.abs(newDistance - lastDistance) <= MAX_DISTANCE_DIFF) {
				// We measured a valid distance sample
				distance = newDistance
				validDistance = true
				val newAngle = opponentPosition.angleInDegrees
				if (angleBuffer.size < MIN_COMP_SAMPLES
						|| Math.abs(newAngle - lastAngle) <= MAX_ANGLE_DIFF) {
					// We measured a valid angle sample
					angle = newAngle
					validAngle = true
				}
			}
		}
		
		if (validDistance) {
			// Reset the number of missed distances
			missedDistances = 0
			// Add the new sample to the buffer and compute the new average
			var sum = lastDistance * distanceBuffer.size
			distanceBuffer.addFirst(distance)
			sum += distance
			if (distanceBuffer.size > DISTANCE_BUFFER_SIZE) {
				sum -= distanceBuffer.removeLast
			}
			distance = sum / distanceBuffer.size
			lastDistance = distance
		} else if (missedDistances < MAX_MISSED_SAMPLES) {
			// Reuse the last computed average distance value
			missedDistances++
			validDistance = true
		}
		
		if (validAngle) {
			// Reset the number of missed angles
			missedAngles = 0
			// Add the new sample to the buffer and compute the new average
			var sum = lastAngle * angleBuffer.size
			angleBuffer.addFirst(angle)
			sum += angle
			if (angleBuffer.size > ANGLE_BUFFER_SIZE) {
				sum -= angleBuffer.removeLast
			}
			angle = sum / angleBuffer.size
			lastAngle = angle
		} else if (missedAngles < MAX_MISSED_SAMPLES) {
			// Reuse the last computed average angle value
			missedAngles++
			validAngle = true
		}
		
		new RobotSight(angle, distance, validAngle && validDistance)
	}
	
}
