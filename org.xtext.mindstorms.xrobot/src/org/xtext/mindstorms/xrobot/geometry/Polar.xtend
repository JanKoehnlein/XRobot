package org.xtext.mindstorms.xrobot.geometry

import org.eclipse.xtend.lib.annotations.Data

@Data
class Polar {
	
	public static val INVALID = new Polar(0, Float.MAX_VALUE)
	
	/** 
	 * in degrees
	 */
	float angle
	
	/**
	 * in cm. Sorry, Americans :-)
	 */
	float distance
	
	def boolean isValid() {
		this != INVALID
	}
}