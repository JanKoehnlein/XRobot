/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.camera

import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.api.Vector

/**
 * A sample from the camera server contains position data of the receiving robot and
 * position data of the opponent robot.
 */
@Data class CameraSample {
	
	/** The position data of the receiving robot. */
	RobotPosition ownPosition
	
	/** The time at which the own position was delivered. */
	long ownTimestamp
	
	/** The position data of the opponent robot. */
	RobotPosition opponentPosition
	
	/** The time at which the opponent position was delivered. */
	long opponentTimestamp
	
	/** Create a camera sample with all values set to zero. */
	static def zeroSample() {
		new CameraSample(new RobotPosition(0, 0, Vector.zero, 0, 0), 0,
			new RobotPosition(0, 0, Vector.zero, 0, 0), 0)
	}
	
}
