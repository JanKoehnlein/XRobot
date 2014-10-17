package org.xtext.xrobot.util

/**
 * A filter that combines new samples with the current values using factors.
 */
class MultiplyingFilter extends AbstractValueStreamFilter {
	
	val double lastValueFactor;
	
	new(double lastValueFactor) {
		if (lastValueFactor < 0 || lastValueFactor > 1)
			throw new IllegalArgumentException
		this.lastValueFactor = lastValueFactor
	}
	
	new(double lastValueFactor, double periodicity) {
		super(periodicity)
		if (lastValueFactor < 0 || lastValueFactor > 1)
			throw new IllegalArgumentException
		this.lastValueFactor = lastValueFactor
	}

	override protected double doApply(double currentValue, double historyOffset) {
		if (!Double.isNaN(currentValue)) {
			lastValue = lastValueFactor * lastValue + (1 - lastValueFactor) * currentValue
		}

		return lastValue
	}
	
}
