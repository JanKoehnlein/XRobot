/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import javafx.util.Duration

interface IErrorReporter {
	
	def void showError(String message, Duration duration)
	
	def void showWarning(String message, Duration duration)
	
	def void showInfo(String message, Duration duration)
	
	def void showMessage(String message, String stylePrefix, Duration duration) 
}