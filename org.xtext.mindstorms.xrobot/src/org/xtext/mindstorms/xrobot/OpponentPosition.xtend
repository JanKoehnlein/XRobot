package org.xtext.mindstorms.xrobot

import org.eclipse.xtend.lib.annotations.Data

import static java.lang.Math.*

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
	double rawAngular
	double rawDistance
	
	def boolean isDetected() {
		rawDistance < 128
	}
	
	/** 
	 * The approximate measured angle in degrees.
	 */
	def double getAngleInDegrees() {
		atan(0.18 * rawAngular) * 90.0 / PI
	}
	
	/** 
	 * The approximate measured sensor to remote distance in cm.
	 */
	def double getDistanceInCentimeter() {
		2 * rawDistance
	}
}