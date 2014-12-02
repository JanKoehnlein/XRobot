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
			sleep(4000)
		}
	'''
	
	val PINGPONG = '''
		robot PingPong
		author Miro
		
		var doPing = true
		
		Ping on doPing {
			say('Ping')
			sleep(2000)
			doPing = false
		}
		
		Pong {
			say('Pong')
			sleep(2000)
			doPing = true
		}
	'''
	
	val LAMBDA = '''
		robot lambda_robot
		author lambda_author
		
		var foo = [|rotate(90)]
		
		now {
			foo.apply
		}
	'''
}