package org.xtext.xrobot.util

import java.util.LinkedList

/**
 * A filter that computes the average value using buffers.
 */
class AveragingFilter implements IValueStreamFilter {
	
	val buffer = new LinkedList<Double>
	val int maxBufferSize;
	
	var lastValue = 0.0
	
	new(int maxBufferSize) {
		this.maxBufferSize = maxBufferSize
	}

	override double apply(double currentValue) {
		var sum = lastValue * buffer.size
		buffer.addFirst(currentValue)
		sum += currentValue
		if (buffer.size > maxBufferSize) {
			sum -= buffer.removeLast
		}
		lastValue = sum / buffer.size
		
		return lastValue
	}
	
}
