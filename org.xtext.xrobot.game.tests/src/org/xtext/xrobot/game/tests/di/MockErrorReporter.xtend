package org.xtext.xrobot.game.tests.di

import org.xtext.xrobot.game.IErrorReporter

class MockErrorReporter implements IErrorReporter {
	
	override showError(String message) {
		println("##Error: " + message)
	}
	
	override showInfo(String message) {
		println("##Info: " + message)
	}
	
	override showWarning(String message) {
		println("##Warning: " + message)
	}
	
}