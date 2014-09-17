package org.xtext.xrobot.util

/**
 * A filter on a data stream for eliminating outliers.
 */
interface IValueStreamFilter {
	
	def double apply(double currentValue)
	
}