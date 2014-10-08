package org.xtext.xrobot.server

class CanceledException extends RuntimeException {
	
	new(String message) {
		super(message)
	}
	
	new() {
		super()
	}
}