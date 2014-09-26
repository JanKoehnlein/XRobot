package org.xtext.xrobot.game

import java.util.Random
import org.eclipse.xtend.lib.annotations.Data

import static java.lang.Math.*

@Data
class AccessToken {
	
	static val TOKEN_SIZE = 4
	
	String value 
	
	new(String token) {
		value = token.substring(0, min(TOKEN_SIZE, token.length))
	}
	
	new() {
		val b = newCharArrayOfSize(TOKEN_SIZE)
		val random = new Random()
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