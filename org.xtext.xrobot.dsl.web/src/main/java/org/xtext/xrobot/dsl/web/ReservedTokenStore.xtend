/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.xrobot.dsl.web

import com.google.common.collect.HashMultimap
import com.google.common.collect.LinkedHashMultimap
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Data

class ReservedTokenStore {
	
	public static final val MAX_AGE = 1000l * 60 * 10 // 10 minutes in millis
	public static final val MAX_SCRIPT_SIZE = 65536
	public static final val MAX_SCRIPTS_PER_ADDRESS = 50
	
	val token2entry = <String, Entry>newHashMap
	val address2entry = HashMultimap.<String, Entry>create
	val time2entry = LinkedHashMultimap.<Long, Entry>create
	
	def ExecutorResult add(Entry entry, String address) {
		if (entry.source.length > MAX_SCRIPT_SIZE) {
			Thread.sleep(50)
			return new ExecutorResult('Script limit of 64k exceeded')
		}
		if (address2entry.get(address).size > MAX_SCRIPTS_PER_ADDRESS) {
			Thread.sleep(50)
			return new ExecutorResult('Too many pending entries from the same address')
		}
		val token = entry.token.toUpperCase
		val existingEntry = token2entry.get(token)
		if (existingEntry != null) {
			Thread.sleep(50)
			return new ExecutorResult('Token already reserved')
		}
		if (entry.uri.startsWith('src/')) {
			val fileName = entry.uri.substring(4)
			if (!fileName.contains('/') && fileName.endsWith('.xrobot')) {
				val timestamp = System.currentTimeMillis
				val newEntry = new Entry(timestamp, token, address, fileName, entry.source)
				token2entry.put(token, newEntry)
				address2entry.put(address, newEntry)
				time2entry.put(timestamp, newEntry)
				collectGarbage(MAX_AGE)
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
		for (timeStamp: new ArrayList(time2entry.keySet)) {
			if (timeStamp + maxAge < now) {
				for (entry: new ArrayList<Entry>(time2entry.get(timeStamp))) {
					token2entry.remove(entry.token)
					address2entry.remove(entry.address, entry)
				}
				time2entry.removeAll(timeStamp)					
			} else {
				return
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
	public static class ExecutorResult {
		String output
	}
	
}
