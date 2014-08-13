package org.xtext.mindstorms.xrobot

import lejos.hardware.BrickFinder
import lejos.hardware.Button
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
				val enemyBearing = robot.measureEnemyBearing
				return (abs(enemyBearing.angle) < 3 && enemyBearing.distance < 10)
					|| robot.measureShieldContact > 0.5
				
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
				val enemyBearing = robot.measureEnemyBearing
				enemyBearing.valid && abs(enemyBearing.angle) < 12
			}
			
			override getPriority() {
				20
			}
			
			override run(IRobot robot) {
				val enemyBearing = robot.measureEnemyBearing
				robot.curveTo(enemyBearing)
			}
			
			override stop(IRobot robot) {
			}
		})
		
		program.addSubProgram(new ISubProgram() {
			
			override getName() {
				'face enemy'				
			}
			
			override checkCondition(IRobot robot) {
				val enemyBearing = robot.measureEnemyBearing
				enemyBearing.valid
			}
			
			override getPriority() {
				10
			}
			
			override run(IRobot robot) {
				val angle = robot.measureEnemyBearing.angle
				robot.rotate(-90 * angle / 25)
			}
			
			override stop(IRobot robot) {
			}
		})
	
		
		program.run(robot)
		Button.waitForAnyPress
	}
	
}