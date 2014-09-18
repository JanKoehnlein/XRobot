package org.xtext.xrobot.camera

import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.api.RobotPosition

@Data class CameraSample {
	
	RobotPosition ownPosition
	
	long ownTimestamp
	
	RobotPosition opponentPosition
	
	long opponentTimestamp
	
}
