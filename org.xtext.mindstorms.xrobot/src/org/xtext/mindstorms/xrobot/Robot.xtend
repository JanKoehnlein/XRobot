package org.xtext.mindstorms.xrobot

import lejos.hardware.Brick
import lejos.hardware.Key
import lejos.hardware.LED
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.hardware.sensor.EV3ColorSensor
import lejos.hardware.sensor.EV3IRSensor
import lejos.hardware.sensor.EV3TouchSensor
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.mindstorms.xrobot.data.SensorSample

import static extension java.lang.Math.*

class Robot implements IRobot {
	
	DifferentialPilot pilot

	NXTRegulatedMotor weaponMotor

	EV3IRSensor irSensor
	
	EV3ColorSensor colorSensor

	EV3TouchSensor touchSensor
	
	LED led

	Key escapeKey
	
	String name
	
	int channel

	new(Brick brick) {
		pilot = new DifferentialPilot(4.32, 9.50, 
			new NXTRegulatedMotor(brick.getPort('B')), 
			new NXTRegulatedMotor(brick.getPort('C')))
		weaponMotor = new NXTRegulatedMotor(brick.getPort('A'))
		irSensor = new EV3IRSensor(brick.getPort('S4'))
		colorSensor = new EV3ColorSensor(brick.getPort('S3'))
		touchSensor = new EV3TouchSensor(brick.getPort('S1'))	
		escapeKey = brick.getKey('Escape')
		led = brick.LED
		name = brick.name
		this.channel = if(name == 'Xtend') 1 else 2
	}
	
	override getName() {
		name
	}
	
	override escapePressed() {
		escapeKey.down
	}
	
	def measureDistance() {
		val sample = newFloatArrayOfSize(1)
		irSensor.distanceMode.fetchSample(sample, 0)
		return sample.get(0) 
	}
	
	def float[] measureEnemyBearings() {
		val sample = newFloatArrayOfSize(8)
		irSensor.seekMode.fetchSample(sample, 0)
		return sample
	}
	
	def measureGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.redMode.fetchSample(sample, 0)
		return sample.get(0)
	}
	
	def measureShieldContact() {
		val sample = newFloatArrayOfSize(1)
		touchSensor.touchMode.fetchSample(sample, 0)
		return sample.get(0)
	}
	
	override forward(double distance) {
		pilot.travel(distance)
	}
	
	override backward(double distance) {
		pilot.travel(-distance)
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
		pilot.rotate(angle)
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
		pilot.arc(radius, angle)
	}
	
	override curveBackward(double radius, double angle) {
		pilot.arc(radius, -angle)
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
			measureDistance, measureGroundColor, measureShieldContact)
	}	
	
	override stop() {
		pilot.stop
	}
	
	override fireWeapon() {
		weaponMotor.speed = weaponMotor.maxSpeed
		weaponMotor.rotateTo(180)
		weaponMotor.rotateTo(0)
	}
	
	def setLed(int pattern) {
		led.pattern = pattern
	}
	
}