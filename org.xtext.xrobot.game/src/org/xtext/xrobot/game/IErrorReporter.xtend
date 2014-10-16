package org.xtext.xrobot.game

import javafx.util.Duration

interface IErrorReporter {
	
	def void showError(String message, Duration duration)
	
	def void showWarning(String message, Duration duration)
	
	def void showInfo(String message, Duration duration)
	
	def void showMessage(String message, String stylePrefix, Duration duration) 
}