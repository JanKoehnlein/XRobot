package org.xtext.xrobot.game

import java.util.Random
import org.eclipse.xtend.lib.annotations.Data

@Data
class AccessToken {
	
	static val TOKEN_SIZE = 4
	
	String value 
	
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