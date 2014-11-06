package org.xtext.xrobot.camera

import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID

class CameraTimeoutException extends RuntimeException {
	
	@Accessors
	val RobotID robotID
	
	new(RobotID robotID) {
		super()
		this.robotID = robotID
	}
	
	new(RobotID robotID, String message) {
		super(message)
		this.robotID = robotID
	}
	
}