/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.util

import java.util.LinkedList

/**
 * A filter that computes the average value using buffers.
 */
class AveragingFilter extends AbstractValueStreamFilter {
	
	val buffer = new LinkedList<Double>
	val int maxBufferSize;
		
	new(int maxBufferSize) {
		if (maxBufferSize <= 0)
			throw new IllegalArgumentException
		this.maxBufferSize = maxBufferSize
	}
	
	new(int maxBufferSize, double periodicity) {
		super(periodicity)
		if (maxBufferSize <= 0)
			throw new IllegalArgumentException
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
