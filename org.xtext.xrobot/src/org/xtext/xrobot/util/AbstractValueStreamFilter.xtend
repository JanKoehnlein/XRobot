package org.xtext.xrobot.util

import static java.lang.Math.*

abstract class AbstractValueStreamFilter implements IValueStreamFilter {
	
	val double periodicity;

	protected var lastValue = 0.0
	
	new() {
		this.periodicity = 0.0
	}
	
	new(double periodicity) {
		if (periodicity < 0) {
			throw new IllegalArgumentException()
		}
		this.periodicity = periodicity
	}
	
	override double apply(double currentValue) {
		var historyOffset = 0.0
		if (periodicity > 0) {
			val delta = abs(lastValue - currentValue)
			if (abs(lastValue + periodicity - currentValue) < delta) {
				historyOffset = periodicity
			} else if (abs(lastValue - periodicity - currentValue) < delta) {
				historyOffset = -periodicity
			}
			lastValue += historyOffset
		}
		doApply(currentValue, historyOffset)
	}
	
	def protected double doApply(double currentValue, double historyOffset)
	
}