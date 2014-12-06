/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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