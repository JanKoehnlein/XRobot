package org.xtext.xrobot.util

import java.lang.Exception

/**
 * An exception indicating that the batteries of the robot are almost empty and should be replaced.
 */
class EmptyBatteriesException extends Exception {
	
	new(String message) {
		super(message)
	}
	
	new(String message, Throwable cause) {
		super(message, cause)
	}
	
}