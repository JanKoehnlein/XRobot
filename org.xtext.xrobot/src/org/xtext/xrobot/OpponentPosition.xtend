package org.xtext.xrobot

import org.eclipse.xtend.lib.annotations.Data

/**
 * A class representing the position of the opponent as measured by 
 * the robot's IR sensor.
 * 
 * The sensor reports values between -25 and 25 for the angular 
 * component and 0 to 127 for the distance. You can use these values 
 * as {@link #getRawAngular()} or {@link #getRwaDistance()} or use 
 * {@link #getAngleInDegrees()} and {@link #getDistanceInCentimeter()} 
 * to transform them to real world units. 
 * 
 * If the opponent cannot be detected, the sensor reports 0 as angle 
 * and 128 as distance. Use {@link #isDetected()} for convenience.
 */
@Data
class OpponentPosition {

	float[] rawData
	int channel
	
	def double getRawAngular() {
		val opponentIndex = (2-channel)*2
		rawData.get(opponentIndex)
	}
		
	def double getRawDistance() {
		val opponentIndex = (2-channel)*2
		rawData.get(opponentIndex + 1)
	}
		
	def boolean isDetected() {
		rawDistance < 100 
	}
	
	/** 
	 * The approximate measured angle in degrees.
	 */
	def double getAngleInDegrees() {
		1.6 * rawAngular + 3.0
	}
	
	/** 
	 * The approximate measured sensor to remote distance in cm.
	 */
	def double getDistanceInCentimeters() {
		2 * rawDistance
	}
}