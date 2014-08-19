package org.xtext.mindstorms.xrobot

import lejos.hardware.Audio
import lejos.hardware.Brick
import lejos.hardware.Key
import lejos.hardware.LED
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.hardware.sensor.EV3ColorSensor
import lejos.hardware.sensor.EV3IRSensor
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.mindstorms.xrobot.annotations.NoAPI
import org.xtext.mindstorms.xrobot.annotations.SimpleRMI
import org.xtext.mindstorms.xrobot.annotations.SubComponent
import org.xtext.mindstorms.xrobot.data.SensorSample
import org.xtext.mindstorms.xrobot.util.SoundUtil

import static extension java.lang.Math.*

@SimpleRMI
class Robot {
	
	DifferentialPilot pilot

	EV3IRSensor irSensor
	 
	EV3ColorSensor colorSensor

//	EV3TouchSensor touchSensor
	
	LED led

	Key escapeKey
	
	Audio audio
	
	String name
	
	int channel

	extension SoundUtil = new SoundUtil
		
	@SubComponent Motor leftMotor
	@SubComponent Motor rightMotor
	@SubComponent Motor scoopMotor
	
	new(Brick brick) {
		val leftRegMotor = new NXTRegulatedMotor(brick.getPort('B'))
		val rightRegMotor = new NXTRegulatedMotor(brick.getPort('C'))
		leftMotor = new Motor(leftRegMotor)
		rightMotor = new Motor(rightRegMotor)
		pilot = new DifferentialPilot(4.32, 9.50, leftRegMotor, rightRegMotor)
		scoopMotor = new Motor(new NXTRegulatedMotor(brick.getPort('A')))
		irSensor = new EV3IRSensor(brick.getPort('S2'))
		colorSensor = new EV3ColorSensor(brick.getPort('S3'))
//		touchSensor = new EV3TouchSensor(brick.getPort('S1'))	
		escapeKey = brick.getKey('Escape')
		led = brick.LED
		audio = brick.audio
		name = brick.name
		this.channel = if(name == 'Xtend') 1 else 2
		scoopMotor.speed = scoopMotor.maxSpeed as int
	}
	
	override getName() {
		name
	}
	
	override getTime() {
		System.currentTimeMillis
	}
	override escapePressed() {
		escapeKey.down
	}
	
	override measureDistance() {
		val sample = newFloatArrayOfSize(1)
		irSensor.distanceMode.fetchSample(sample, 0)
		return sample.get(0) 
	}
	
	protected def float[] measureEnemyBearings() {
		val sample = newFloatArrayOfSize(8)
		irSensor.seekMode.fetchSample(sample, 0)
		return sample
	}
	
	override measureGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.redMode.fetchSample(sample, 0)
		return sample.get(0)
	}
	
//	override measureShieldContact() {
//		val sample = newFloatArrayOfSize(1)
//		touchSensor.touchMode.fetchSample(sample, 0)
//		return sample.get(0)
//	}
	
	override forward(double distance) {
		pilot.travel(distance, true)
	}
	
	override backward(double distance) {
		pilot.travel(-distance, true)
	}
	
	override setTravelSpeed(double speed) {
		pilot.travelSpeed = speed
	}
	
	override getTravelSpeed() {
		pilot.travelSpeed
	}
	
	override getMaxTravelSpeed() {
		pilot.maxTravelSpeed
	}
	
	override rotate(double angle) {
		pilot.rotate(angle, true)
	}
	
	override setRotateSpeed(double speed) {
		pilot.rotateSpeed = rotateSpeed
	}
	
	override getRotateSpeed() {
		pilot.rotateSpeed
	}
	
	override getRotateMaxSpeed() {
		pilot.rotateMaxSpeed
	}
	
	override curveForward(double radius, double angle) {
		pilot.arc(radius, angle, true)
	}
	
	override curveBackward(double radius, double angle) {
		pilot.arc(radius, -angle, true)
	}
	
	override curveTo(double angle, double distance) {
		val radius = 0.5 * distance * cos(0.5 * PI - angle.toRadians)
		curveForward(radius, angle)
	}
	
	override sample() {
		val time = System.currentTimeMillis
		val bearings = measureEnemyBearings
		val enemyIndex = (2 - channel) * 2
		new SensorSample(time, 
			bearings.get(enemyIndex), bearings.get(enemyIndex + 1),
			0/*measureDistance*/, measureGroundColor/* , measureShieldContact*/)
	}	
	
	override stop() {
		pilot.stop
	}
	
	override scoop(double angle) {
		scoopMotor.rotate(angle as int)
	}
	
	override playSample(String fileName, int volume) {
		audio.playSample('samples/' + fileName + '.wav', volume)
	}	
	
	@NoAPI
	def setLed(int pattern) {
		led.pattern = pattern
	}
	
}