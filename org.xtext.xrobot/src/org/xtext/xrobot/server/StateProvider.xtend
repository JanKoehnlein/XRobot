package org.xtext.xrobot.server

interface StateProvider<T> {
	def T getState()
}