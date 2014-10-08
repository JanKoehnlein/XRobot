package org.xtext.xrobot.game

interface IErrorReporter {
	
	def void showError(String message)
	
	def void showWarning(String message)
	
	def void showInfo(String message)
}