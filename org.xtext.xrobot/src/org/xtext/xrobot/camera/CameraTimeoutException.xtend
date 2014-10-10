package org.xtext.xrobot.camera

import java.lang.RuntimeException

class CameraTimeoutException extends RuntimeException {
	
	new() {
		super()
	}
	
	new(String message) {
		super(message)
	}
	
}