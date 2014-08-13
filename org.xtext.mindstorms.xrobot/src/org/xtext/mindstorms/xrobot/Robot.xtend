package org.xtext.mindstorms.xrobot

import lejos.hardware.Brick
import lejos.hardware.Key
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.hardware.sensor.EV3ColorSensor
import lejos.hardware.sensor.EV3IRSensor
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.mindstorms.xrobot.geometry.Polar

import static extension java.lang.Math.*
import lejos.hardware.sensor.EV3TouchSensor

class Robot implements IRobot {
	
	DifferentialPilot pilot

	NXTRegulatedMotor weaponMotor

	EV3IRSensor irSensor
	
	EV3ColorSensor colorSensor

	EV3TouchSensor touchSensor

	Key escapeKey

	new(Brick brick) {
		pilot = new DifferentialPilot(4.32, 13.30, 
			new NXTRegulatedMotor(brick.getPort('B')), 
			new NXTRegulatedMotor(brick.getPort('C')))
		weaponMotor = new NXTRegulatedMotor(brick.getPort('A'))
		irSensor = new EV3IRSensor(brick.getPort('S4'))
		colorSensor = new EV3ColorSensor(brick.getPort('S3'))
		touchSensor = new EV3TouchSensor(brick.getPort('S1'))	
		escapeKey = brick.getKey('Escape')
	}
	
	override escapePressed() {
		escapeKey.down
	}
	
	override measureDistance() {
		val sample = newFloatArrayOfSize(1)
		irSensor.distanceMode.fetchSample(sample, 0)
		return sample.get(0) 
	}
	
	override measureEnemyBearing() {
		val sample = newFloatArrayOfSize(8)
		irSensor.seekMode.fetchSample(sample, 0)
		for(var i=1; i<8; i+=2) {
			if(sample.get(i) < 128) 
				return new Polar(3 * sample.get(i-1), 2 * sample.get(i))
		}
		return Polar.INVALID
	}
	
	override measureGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.redMode.fetchSample(sample, 0)
		return sample.get(0)
	}
	
	override measureShieldContact() {
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
	
	override curveTo(Polar bearing) {
		val angle = bearing.angle.toRadians
		val radius = 0.5 * bearing.distance * cos(0.5 * PI - angle)
		curveForward(radius, angle)
	}
	
	override stop() {
		pilot.stop
	}
	
	override fireWeapon() {
		weaponMotor.speed = weaponMotor.maxSpeed
		weaponMotor.rotateTo(140)
		weaponMotor.rotateTo(0)
	}
	
}