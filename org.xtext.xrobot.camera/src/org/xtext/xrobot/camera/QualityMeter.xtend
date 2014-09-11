package org.xtext.xrobot.camera

class QualityMeter {
	
	val boolean[] success
	int currentIndex = 0
	int numSuccesses = 0
	boolean isWarmingUp = true
	
	new(int historySize) {
		success = newBooleanArrayOfSize(historySize)
	}
	
	def success() {
		add(true)
	}
	
	def failure() {
		add(false)
	}

	def getRate() {
		 numSuccesses as double / if(isWarmingUp) currentIndex else success.length  
	}
	
	private def add(boolean isSuccess) {
		val previous = success.get(currentIndex);
		success.set(currentIndex++, isSuccess) 
		if(isSuccess.xor(previous)) {
			if(isSuccess)
				numSuccesses++
			else
				numSuccesses-- 
		}
		if(currentIndex == success.length) {
			isWarmingUp = false			
			currentIndex = 0
		}
	}
}