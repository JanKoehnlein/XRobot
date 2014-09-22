package org.xtext.xrobot.util

import org.apache.log4j.Logger

class IgnoreExceptionsExtension {
	
	static val LOG = Logger.getLogger(IgnoreExceptionsExtension)
	
	static def ignoreExceptions(()=>void lambda) {
		try {
			lambda.apply
		} catch (Exception exc) {
			LOG.warn('Ignored exception ' + exc.message)		
		}
	}
}