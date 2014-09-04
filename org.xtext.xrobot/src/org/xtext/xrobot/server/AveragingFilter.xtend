package org.xtext.xrobot.server

import java.util.LinkedList
import org.xtext.xrobot.OpponentPosition
import org.xtext.xrobot.api.RobotSight

/**
 * A filter that computes the average position using buffers.
 */
class AveragingFilter implements IRobotSightFilter {
	
	/** The number of samples used for averaging the distance. */
	static val DISTANCE_BUFFER_SIZE = 15
	/** The number of samples used for averaging the angle. */
	static val ANGLE_BUFFER_SIZE = 7
	/** The maximal number of missed samples in a row before the result is marked as invalid. */
	static val MAX_MISSED_SAMPLES = 5
	
	val distanceBuffer = new LinkedList<Double>
	val angleBuffer = new LinkedList<Double>
	
	var lastDistance = 0.0
	var lastAngle = 0.0
	var missedSamples = MAX_MISSED_SAMPLES

	override RobotSight apply(OpponentPosition opponentPosition) {
		var double distance
		var double angle
		var validPosition = false
		if (opponentPosition.detected) {
			// Reset the number of missed samples
			missedSamples = 0

			// Add the new distance to the buffer and compute the new average
			val newDistance = opponentPosition.distanceInCentimeters
			var distanceSum = lastDistance * distanceBuffer.size
			distanceBuffer.addFirst(newDistance)
			distanceSum += newDistance
			if (distanceBuffer.size > DISTANCE_BUFFER_SIZE) {
				distanceSum -= distanceBuffer.removeLast
			}
			distance = distanceSum / distanceBuffer.size
			lastDistance = distance
			
			// Add the new angle to the buffer and compute the new average
			val newAngle = opponentPosition.angleInDegrees
			var angleSum = lastAngle * angleBuffer.size
			angleBuffer.addFirst(newAngle)
			angleSum += newAngle
			if (angleBuffer.size > ANGLE_BUFFER_SIZE) {
				angleSum -= angleBuffer.removeLast
			}
			angle = angleSum / angleBuffer.size
			lastAngle = angle
			
			validPosition = true
		} else if (missedSamples < MAX_MISSED_SAMPLES) {
			// Reuse the last computed average values
			missedSamples++
			distance = lastDistance
			angle = lastAngle
			validPosition = true
		}
				
		new RobotSight(angle, distance, validPosition)
	}
	
}
