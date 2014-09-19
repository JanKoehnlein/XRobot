package org.xtext.xrobot.util

/**
 * A filter that combines new samples with the current values using factors.
 */
class MultiplyingFilter extends AbstractValueStreamFilter {
	
	val double lastValueFactor;
	
	new(double lastValueFactor) {
		this.lastValueFactor = lastValueFactor
	}
	
	new(double lastValueFactor, double periodicity) {
		super(periodicity)
		this.lastValueFactor = lastValueFactor
	}

	override protected double doApply(double currentValue, double historyOffset) {
		lastValue = lastValueFactor * lastValue + (1 - lastValueFactor) * currentValue

		return lastValue
	}
	
}
