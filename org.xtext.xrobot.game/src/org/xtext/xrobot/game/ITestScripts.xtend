package org.xtext.xrobot.game

interface ITestScripts {
	
	val DANCER = '''
		robot Dancer
		author Jan
		
		Dance {
			rotationSpeed = maxRotationSpeed * 0.3
			rotateLeft
			while(true) {
				scoop(1)
				scoop(0)
			}
		}
	'''
	
	val IDLE = '''
		robot Idle
		author Miro
		
		Idle {
			println("working hard...")
			Thread.sleep(4000)
		}
	'''
	
}