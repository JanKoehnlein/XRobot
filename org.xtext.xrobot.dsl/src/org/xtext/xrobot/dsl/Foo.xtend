package org.xtext.xrobot.dsl

import org.xtext.mindstorms.xrobot.api.IRobot

class Foo {
	def main(IRobot it) 
	{
		{
			var maxSpeed = leftMotor.maxSpeed
			var data = sample
			while(data.enemyDetected) {
				{
					leftMotor.forward
					rightMotor.forward
					println(maxSpeed)
					data = sample
					while(data.isEnemyDetected && data.enemyDistanceInCentimeter > 40) {
						val left = (0.02 * (45+data.enemyAngleInDegrees / 2) * maxSpeed) as int
						val right = (0.02 * (45-data.enemyAngleInDegrees / 2) * maxSpeed) as int
						println('left=' + left + '  right=' + right + '  angle=' + data.enemyAngleInDegrees + '  distance=' + data.enemyDistanceInCentimeter)
						leftMotor.speed = left 
						rightMotor.speed = right
						data=sample
					}
					if(data.enemyDetected) {
						println(sample.enemyDistanceInCentimeter)
						rotate(-data.enemyAngleInDegrees)
						forward(40)
						scoop(180)
						scoopMotor.waitComplete
						scoop(-180)
						stop
					}
				}
			}
			stop
		}
	}
}