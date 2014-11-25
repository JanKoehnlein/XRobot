package org.xtext.xrobot.game.demo

import org.eclipse.xtend.lib.annotations.Data

@Data
class ExampleRobot {
	
	enum RobotType {
		NORMAL, PASSIVE, SIMPLE_MOVE
	}

	String id
	
	RobotType type

	String code

	def getURI() {
		id + '.xrobot'
	}	
	
	override toString() {
		id
	}
	
	@Data
	static class Provider {
		
		def getNormalExampleRobots() {
			exampleRobots.filter[type == RobotType.NORMAL].toList
		}
		
		val exampleRobots = #[
			
			new ExampleRobot('Rotor', RobotType.SIMPLE_MOVE, '''
				robot Rotor
				author itemis
				
				Spin {
					startMotors(0.1 * maxDrivingSpeed, -0.3 * maxDrivingSpeed)
					scoop(1)
					scoop(0)
				}
			'''),
			
			new ExampleRobot('Circles', RobotType.SIMPLE_MOVE, '''
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
			
			new ExampleRobot('Square Dance', RobotType.SIMPLE_MOVE, '''
				robot 'Square Dance'
				author itemis
				
				Dance {
					rotationSpeed = 0.5 * maxRotationSpeed
					drivingSpeed = 0.8 * maxDrivingSpeed
					val r = 0.5 * ARENA_INNER_RADIUS
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
			
			new ExampleRobot('Dodger', RobotType.PASSIVE, '''
				robot Dodger
				author itemis
				
				Dodge on opponentBearing.length < 35 {
					if (abs(centerBearing.angle) <= 90)
						drive(30)
					else
						drive(-30)
				}
				
				Taunt {
					if (opponentBearing.angle >= 0)
						rotate(opponentBearing.angle - 75)
					else
						rotate(opponentBearing.angle + 75)
				}
			'''),
			
			new ExampleRobot('Friend Seeker', RobotType.NORMAL, '''
				robot 'Friend Seeker'
				author itemis
				
				var initMode = true
				
				Init on initMode {
					scoop(1)
					initMode = false
				}
				
				Greet on opponentBearing.length < ROBOT_LENGTH + 10 {
					stop
					curveForward(10, 10)
					curveForward(10, -10)
				}
				
				SeekLeft on opponentBearing.angle > 15 {
					rotationSpeed = 0.4 * maxRotationSpeed
					rotateLeft
				}
				
				SeekRight on opponentBearing.angle < -15 {
					rotationSpeed = 0.4 * maxRotationSpeed
					rotateRight
				}
				
				SeekForward {
					driveForward
				}
			'''),
			
			new ExampleRobot('Mad Pirate', RobotType.NORMAL, '''
				robot 'Mad Pirate'
				author itemis
				
				YARRR on abs(target.angle) < 30 {
					driveForward
					scoop(1)
				}
				
				HARRR {
					scoop(0)
					rotate(target.angle)
				}
				
				def target() {
					ownPosition.getRelativePosition(
						opponentPosition.toVector + opponentPosition.actualSpeed)
				}
			'''),
			
			new ExampleRobot('Eat My Shorts', RobotType.NORMAL, '''
				robot 'Eat My Shorts'
				author itemis
				
				var init = true
				var random = new java.util.Random
				
				Start on init {
					if (random.nextBoolean)
						rotate(90)
					else
						rotate(-90)
					driveBackward
					init = false
				}
				
				Stop on centerBearing.length > ARENA_INNER_RADIUS - 25 {
					rotate(minimizeAngle(centerBearing.angle + 180))
					driveBackward
					sleep(2000)
				}
				
				Eat {
					val a = opponentBearing.angle
					if (a >= 0)
						startMotors((90 - a) / 90 * maxDrivingSpeed, -maxDrivingSpeed)
					else
						startMotors(-maxDrivingSpeed, (90 + a) / 90 * maxDrivingSpeed)
				}
			'''),
			
			new ExampleRobot('Johnny Cage', RobotType.NORMAL, '''
				robot 'Johnny Cage'
				author itemis
				
				var isFirstMove = true
				
				Brace on isFirstMove {
					rotate(180)
					isFirstMove = false
				}
				
				Find on opponentBearing.length > 45 || opponentBearing.angle.abs > 30 {
					rotate(opponentBearing.angle + 10 * opponentBearing.angle.signum)
					drive(5)
				}
				
				Kill {
					driveForward
					sleep(400)
					scoop(1)
				} when canceled { 
					stop
					scoop(0)
				}
			'''),
			
			new ExampleRobot('Superduck', RobotType.NORMAL, '''
				robot Superduck
				author itemis
				
				Quak on abs(opponentBearing.angle) < 15 && opponentBearing.length < 40 {
					drive(8)
					scoop(1)
					drive(-4)
					scoop(-0.1)
				}
				
				Quok on abs(opponentBearing.angle) > 50 && opponentBearing.length < 40 {
					if (abs(centerBearing.angle) < 90)
						drive(30)
					else
						drive(-30)
				}
				
				Quik {
					scoop(-0.1)
					rotate(ownPosition.getRelativePosition(
						opponentPosition.toVector + opponentPosition.actualSpeed).angle)
					drive(2)
				}
			'''),
			
			new ExampleRobot('Radioman', RobotType.NORMAL, '''
				robot Radioman
				author itemis
				
				var stepIn = true
				
				StepIn on stepIn {
					rotate(minimizeAngle(centerBearing.angle + 180))
					update
					val distance = -centerBearing.length - 5
					if (targetPos(distance).length < ARENA_INNER_RADIUS
						|| abs(opponentBearing.angle) > 160)
						drive(distance)
					stepIn = false
				}
				
				StepOut on !stepIn {
					rotate(opponentBearing.angle)
					update
					val distance = ARENA_INNER_RADIUS - 10
					if (targetPos(distance).length < ARENA_INNER_RADIUS
						|| abs(opponentBearing.angle) < 20)
						drive(distance)
					stepIn = true
				}
				
				def targetPos(double distance) {
					if (distance >= 0)
						ownPosition.toVector + Vector.polar(distance, ownPosition.viewDirection)
					else
						ownPosition.toVector - Vector.polar(-distance, ownPosition.viewDirection)
				}
			'''),
			
			new ExampleRobot('Drunken Master', RobotType.NORMAL, '''
				robot 'Drunken Master'
				author itemis
				
				var start = true
				
				Hiccup on start {
					val random = new java.util.Random
					if (random.nextBoolean)
						curveBackward(12, 150)
					else
						curveBackward(12, -150)
					start = false
				}
				
				Keg on abs(opponentBearing.angle) <= 90 {
					scoop(0.6)
					curveTo(opponentBearing.length + 20, opponentBearing.angle)
					scoop(0)
				}
				
				Bottle {
					scoop(-0.2)
					if (opponentBearing.angle > 0)
						curveBackward(20, 2 * (180 - opponentBearing.angle) + 10)
					else
						curveBackward(20, 2 * (180 + opponentBearing.angle) + 10)
				}
			''')
			
		]
	}
}