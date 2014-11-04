package org.xtext.xrobot.game.example

import org.eclipse.xtend.lib.annotations.Data

@Data
class ExampleRobot {

	String id
	String code

	def getURI() {
		id + '.xrobot'
	}	
	
	override toString() {
		id
	}
	
	@Data
	static class Provider {
		val exampleRobots = #[
			
			new ExampleRobot('Rotor', '''
				robot Rotor
				author itemis
				
				Spin {
					startMotors(0.3 * maxDrivingSpeed, -0.3 * maxDrivingSpeed)
					scoop(1)
					scoop(0)
				}
			'''),
			
			new ExampleRobot('Circles', '''
				robot Circles
				author itemis
				
				Adjust on (centerBearing.angle - 90).abs > 10 {
					rotationSpeed = 0.5 * maxRotationSpeed
					rotate(centerBearing.angle - 85)
				}
				
				Circle {
					drivingSpeed = 0.8 * maxDrivingSpeed
					curveForward(max(20, centerBearing.length - 5), 360)
				}
			'''),
			
			new ExampleRobot('Square Dance', '''
				robot 'Square Dance'
				author itemis
				
				Dance {
					rotationSpeed = 0.5 * maxRotationSpeed
					drivingSpeed = 0.8 * maxDrivingSpeed
					val r = 0.6 * ARENA_INNER_RADIUS
					val v1 = getBearingTo(Vector.cartesian(r, r))
					rotate(v1.angle)
					drive(v1.length)
					val v2 = getBearingTo(Vector.cartesian(r, -r))
					rotate(minimizeAngle(v2.angle + 180))
					drive(-v2.length)
					val v3 = getBearingTo(Vector.cartesian(-r, -r))
					rotate(v3.angle)
					drive(v3.length)
					val v4 = getBearingTo(Vector.cartesian(-r, r))
					rotate(minimizeAngle(v4.angle + 180))
					drive(-v4.length)
				}
				
				def getBearingTo(Vector point) {
					scoop(-1)
					scoop(0)
					update
					ownPosition.getRelativePosition(point)
				}
			'''),
			
			new ExampleRobot('Dodger', '''
				robot Dodger
				author itemis
				
				Dodge on opponentBearing.length < 30 {
					if (abs(centerBearing.angle) <= 90)
						drive(30)
					else
						drive(-30)
				}
				
				Taunt {
					if (opponentBearing.angle >= 0)
						rotate(opponentBearing.angle - 80)
					else
						rotate(opponentBearing.angle + 80)
				}
			'''),
			
			new ExampleRobot('Friendly Seeker', '''
				robot 'Friendly Seeker'
				author itemis
				
				var initMode = true
				
				Init on initMode {
					drivingSpeed = 0.5 * maxDrivingSpeed
					rotationSpeed = 0.3 * maxRotationSpeed
					scoop(1)
					initMode = false
				}
				
				SeekLeft on opponentBearing.angle > 15 {
					rotateLeft
				}
				
				SeekRight on opponentBearing.angle < -15 {
					rotateRight
				}
				
				SeekForward on opponentBearing.length > 30 {
					driveForward
				}
				
				Greet {
					stop
					say('Hello, friend!')
					sleep(5000)
				}
			''')
			
		]
	}
}