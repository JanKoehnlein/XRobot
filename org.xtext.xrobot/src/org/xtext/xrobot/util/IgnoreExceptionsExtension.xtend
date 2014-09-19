package org.xtext.xrobot.util

class IgnoreExceptionsExtension {
	
	static def ignoreExceptions(()=>void lambda) {
		try {
			lambda.apply
		} catch (Exception exc) {
			System.err.println('Ignored exception ' + exc.message)		
		}
	}
}