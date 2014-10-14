package org.xtext.xrobot.dsl.interpreter

import java.lang.Exception

class MemoryException extends Exception {
	
	new(String message) {
		super(message)
	}
	
	new(String message, Throwable cause) {
		super(message, cause)
	}
	
}