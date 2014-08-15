package org.xtext.mindstorms.xrobot.util

class Stopwatch {
	
	long start
	
	new() {
		start()		
	}
	
	def start() {
		start = System.currentTimeMillis
	}

	def stop() {
		val duration = System.currentTimeMillis - start
		start = 0
		return duration
	}

	def split() {
		val now = System.currentTimeMillis
		return now - start
	}
}