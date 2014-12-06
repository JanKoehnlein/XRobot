/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import org.xtext.xrobot.game.IErrorReporter
import javafx.util.Duration

class MockErrorReporter implements IErrorReporter {
	
	override showError(String message, Duration duration) {
		println("##Error: " + message)
	}
	
	override showInfo(String message, Duration duration) {
		println("##Info: " + message)
	}
	
	override showWarning(String message, Duration duration) {
		println("##Warning: " + message)
	}
	
	override showMessage(String message, String stylePrefix, Duration duration) {
		println("##Message: " + message)
	}
	
}