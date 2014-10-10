package org.xtext.xrobot.game.tests

interface TestScripts {
	
	val DANCER = '''
		robot Dancer
		author Jan
		
		Dance {
			say('Eat my shorts!')
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
			play(R2D2)
			println("working hard...")
			Thread.sleep(4000)
		}
	'''
	
	val FILE_READ = '''
		robot FileReader
		author Miro
		
		Evil {
			println(new FileReader("/Users/spoenemann/.profile ").read())
		}
	'''
	
}