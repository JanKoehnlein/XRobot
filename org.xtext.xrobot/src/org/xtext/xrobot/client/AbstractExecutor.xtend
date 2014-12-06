/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.client

import java.io.IOException
import org.apache.log4j.Logger
import org.xtext.xrobot.net.SocketInputBuffer

abstract class AbstractExecutor {
	
	static val LOG = Logger.getLogger(AbstractExecutor)
	static val RELEASE_MESSAGE = -1
	
	protected SocketInputBuffer input
	
	new(SocketInputBuffer input) {
		this.input = input
	}
	
	def dispatchAndExecute(boolean isAlive) throws IOException {
		val componentID = input.readInt
		val subComponent = getSubComponent(componentID)
		if(subComponent != null)
			return subComponent.executeNext(isAlive)
		else
			return true
	}
	
	abstract def AbstractExecutor getSubComponent(int comonentID)
	
	protected def boolean executeNext(boolean isAlive) {
		val messageType = input.readInt
		execute(messageType, isAlive)
	}

	protected def execute(int messageType, boolean isAlive) {
		switch messageType {
			case RELEASE_MESSAGE:
				return false
			default: {
				LOG.error('Illegal message type ' + messageType)
			}
		}
		return true
	}
	
}