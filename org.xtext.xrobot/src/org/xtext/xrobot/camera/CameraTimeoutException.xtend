/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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