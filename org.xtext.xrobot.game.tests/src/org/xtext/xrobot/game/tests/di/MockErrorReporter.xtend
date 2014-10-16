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