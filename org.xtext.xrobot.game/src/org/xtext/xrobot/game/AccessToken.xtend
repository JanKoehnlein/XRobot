/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import java.util.Random
import org.eclipse.xtend.lib.annotations.Data

import static java.lang.Math.*

@Data
class AccessToken {
	
	static val TOKEN_SIZE = 4
	static val random = new Random()
	
	String value 
	
	new(String token) {
		value = token.substring(0, min(TOKEN_SIZE, token.length)).toUpperCase
	}
	
	new() {
		val b = newCharArrayOfSize(TOKEN_SIZE)
		for(i: 1..TOKEN_SIZE) {
			val n = random.nextDouble * 36 as int
			b.set(i - 1, switch n {
				case n<26:
					n+65
				default:
					n+22 						
			} as char) 
		}
		value = new String(b)
	}
}