package org.xtext.mindstorms.xrobot

import lejos.hardware.BrickFinder
import lejos.hardware.Button
import org.xtext.mindstorms.xrobot.api.IRobot
import org.xtext.mindstorms.xrobot.util.SoundUtil

import static java.lang.Math.*

class XRobot {
	
	extension SoundUtil soundUtil = new SoundUtil
	
	def static void main(String[] args) {
		new XRobot().run
	}
	
	def run() {
		val brick = BrickFinder.getDefault
//		brick.audio.playSample('samples/futile.wav', 100)
		val robot = new Robot(brick)
		val program = new Program()
		
		program.addSubProgram(new ISubProgram() {
			override getName() {
				'seek'				
			}
			
			override checkCondition(IRobot robot) {
				true
			}
			
			override getPriority() {
				0
			}
			
			override run(IRobot robot) {
				robot.curveForward(10, 360)
			}
			
			override stop(IRobot robot) {
				robot.stop
			}
		})
		
		program.addSubProgram(new ISubProgram() {
			
			override getName() {
				'punch'				
			}
			
			override checkCondition(IRobot robot) {
				val sample = robot.sample
				return (abs(sample.enemyAngle) < 3 && sample.enemyDistance < 20)
					|| sample.contact > 0.5
				
			}
			
			override getPriority() {
				25
			}
			
			override run(IRobot robot) {
				robot.fireWeapon
			}
			
			override stop(IRobot robot) {
			}
		})
		
		program.addSubProgram(new ISubProgram() {
			
			override getName() {
				'attack'				
			}
			
			override checkCondition(IRobot robot) {
				val sample = robot.sample
				sample.enemyDetected && abs(sample.enemyAngle) < 12
			}
			
			override getPriority() {
				20
			}
			
			override run(IRobot robot) {
				val sample = robot.sample
				robot.curveTo(sample.enemyAngleInDegrees, sample.enemyDistanceInCentimeter)
			}
			
			override stop(IRobot robot) {
			}
		})
		
		program.addSubProgram(new ISubProgram() {
			
			override getName() {
				'face enemy'				
			}
			
			override checkCondition(IRobot robot) {
				robot.sample.enemyDetected
			}
			
			override getPriority() {
				10
			}
			
			override run(IRobot robot) {
				val angle = robot.sample.enemyAngleInDegrees
				robot.rotate(-90 * angle / 25)
			}
			
			override stop(IRobot robot) {
			}
		})
	
		
		program.run(robot)
		Button.waitForAnyPress
	}
}