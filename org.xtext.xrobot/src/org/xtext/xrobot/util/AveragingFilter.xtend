package org.xtext.xrobot.util

import java.util.LinkedList

/**
 * A filter that computes the average value using buffers.
 */
class AveragingFilter extends AbstractValueStreamFilter {
	
	val buffer = new LinkedList<Double>
	val int maxBufferSize;
		
	new(int maxBufferSize) {
		this.maxBufferSize = maxBufferSize
	}
	
	new(int maxBufferSize, double periodicity) {
		super(periodicity)
		this.maxBufferSize = maxBufferSize
	}

	override protected double doApply(double currentValue, double historyOffset) {
		// Adapt the buffer with the given offset
		if (historyOffset != 0) {
			val iterator = buffer.listIterator
			while (iterator.hasNext) {
				val x = iterator.next
				iterator.set(x + historyOffset)
			}
		}
		
		// Compute the new average value
		var sum = lastValue * buffer.size
		if (!Double.isNaN(currentValue)) {
			buffer.addFirst(currentValue)
			sum += currentValue
			if (buffer.size > maxBufferSize) {
				sum -= buffer.removeLast
			}
		}
		if (buffer.empty) {
			lastValue = Double.NaN
		} else {
			lastValue = sum / buffer.size
		}
		
		return lastValue
	}
	
}
