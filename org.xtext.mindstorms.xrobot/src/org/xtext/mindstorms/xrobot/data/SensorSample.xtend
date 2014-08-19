package org.xtext.mindstorms.xrobot.data

import org.eclipse.xtend.lib.annotations.Data

import static java.lang.Math.*

@Data
class SensorSample {
	long timestamp
	double enemyAngle
	double enemyDistance
	double distance  
	double groundColor
//	double contact
	
	def isEnemyDetected() {
		enemyDistance < 128
	}
	
	/** 
	 * The approximate measured angle in degrees.
	 */
	def getEnemyAngleInDegrees() {
		atan(0.18 * enemyAngle) * 90.0 / PI
	}
	
	/** 
	 * The approximate measured sensor to remote distance in cm.
	 */
	def getEnemyDistanceInCentimeter() {
		2 * enemyDistance
	}
}