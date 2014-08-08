package org.xtext.mindstorms.xrobot

import lejos.hardware.Brick
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.hardware.sensor.EV3ColorSensor
import lejos.hardware.sensor.EV3IRSensor
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.mindstorms.xrobot.geometry.Point
import org.xtext.mindstorms.xrobot.geometry.Polar

import static extension java.lang.Math.*

class Robot implements IRobot {
	
	DifferentialPilot pilot

	EV3IRSensor irSensor
	
	EV3ColorSensor colorSensor

	Point position = new Point(0, 0)
	
	double bearing
	
	new(Brick brick) {
		pilot = new DifferentialPilot(43.2, 133.0, 
			new NXTRegulatedMotor(brick.getPort("B")), 
			new NXTRegulatedMotor(brick.getPort("C")))
		irSensor = new EV3IRSensor(brick.getPort("S4"))
		colorSensor = new EV3ColorSensor(brick.getPort("S3"))	
	}
	
	override getPosition() {
		position
	}
	
	override getBearing() {
		bearing.toDegrees
	}
	
	override rotate(double angle) {
		pilot.rotate(angle)
		bearing += angle.toRadians
	}
	
	override forward(double distance) {
		pilot.travel(distance)
		position = position + new Point(cos(bearing) * distance, sin(bearing) * distance) 
	}

	override backward(double distance) {
		pilot.travel(-distance)
		position = position - new Point(cos(bearing) * distance, sin(bearing) * distance) 
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
			if(sample.get(i) < 255) 
				return new Polar(sample.get(i-1), sample.get(i))
		}
		return null
	}
	
	override measureGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.redMode.fetchSample(sample, 0)
		return sample.get(0)
	}
}