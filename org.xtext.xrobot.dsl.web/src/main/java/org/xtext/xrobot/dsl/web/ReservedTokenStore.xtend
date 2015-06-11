/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import com.google.common.collect.HashMultimap
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.web.server.IServiceResult

class ReservedTokenStore {
	
	public static final val MAX_AGE = 1000l * 60 * 10 // 10 minutes in millis
	public static final val MAX_SCRIPT_SIZE = 65536
	public static final val MAX_SCRIPTS_PER_ADDRESS = 50
	
	val token2entry = <String, Entry>newHashMap
	val address2entry = HashMultimap.<String, Entry>create
	
	def ExecutorResult add(String source, String uri, String token, String address) {
		if (source.length > MAX_SCRIPT_SIZE) {
			Thread.sleep(50)
			return new ExecutorResult('Script limit of 64k exceeded')
		}
		if (!token.matches('\\w+') || token.length != 4) {
			Thread.sleep(50)
			return new ExecutorResult('The token format is incorrect.')
		}
		synchronized (token2entry) {
			collectGarbage(MAX_AGE)
			if (address2entry.get(address).size > MAX_SCRIPTS_PER_ADDRESS) {
				Thread.sleep(50)
				return new ExecutorResult('Too many pending entries from the same address')
			}
			val ucToken = token.toUpperCase
			val existingEntry = token2entry.get(ucToken)
			if (existingEntry != null) {
				Thread.sleep(50)
				return new ExecutorResult('Token already reserved')
			}
			if (!uri.contains('/') && uri.endsWith('.xrobot')) {
				val timestamp = System.currentTimeMillis
				val newEntry = new Entry(timestamp, ucToken, address, uri, source)
				token2entry.put(ucToken, newEntry)
				address2entry.put(address, newEntry)
				return new ExecutorResult('Token successfully reserved')
			}
		}
		Thread.sleep(50)
		return new ExecutorResult('Invalid URI')
	}
	
	def Entry get(String token) {
		token2entry.get(token.toUpperCase)
	}
	
	protected def collectGarbage(long maxAge) {
		val now = System.currentTimeMillis
		val entryIter = token2entry.values.iterator
		while (entryIter.hasNext) {
			val entry = entryIter.next
			if (entry.timestamp + maxAge < now) {
				entryIter.remove
				address2entry.remove(entry.address, entry)					
			}
		}
	}
	
	@Data
	public static class Entry {
		long timestamp
		String token
		String address
		String uri
		String source
	}
	
	@Data
	public static class ExecutorResult implements IServiceResult {
		String output
	}
	
}
