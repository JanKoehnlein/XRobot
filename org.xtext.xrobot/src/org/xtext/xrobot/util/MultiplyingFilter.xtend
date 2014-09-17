package org.xtext.xrobot.util

/**
 * A filter that combines new samples with the current values using factors.
 */
class MultiplyingFilter implements IValueStreamFilter {
	
	val double lastValueFactor;
	
	var lastValue = 0.0
	
	new(double lastValueFactor) {
		this.lastValueFactor = lastValueFactor
	}

	override double apply(double currentValue) {
		lastValue = lastValueFactor * lastValue + (1 - lastValueFactor) * currentValue

		return lastValue
	}
	
}
