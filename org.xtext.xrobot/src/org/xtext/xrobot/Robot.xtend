package org.xtext.xrobot

import lejos.hardware.Audio
import lejos.hardware.Brick
import lejos.hardware.Key
import lejos.hardware.LED
import lejos.hardware.Power
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.hardware.sensor.EV3ColorSensor
import lejos.hardware.sensor.EV3IRSensor
import lejos.hardware.sensor.SensorMode
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.xrobot.annotations.NoAPI
import org.xtext.xrobot.annotations.SimpleRMI
import org.xtext.xrobot.annotations.SubComponent
import org.xtext.xrobot.util.SoundUtil

import static extension java.lang.Math.*

@SimpleRMI
class Robot implements IRobotGeometry {
	
	DifferentialPilot pilot

	SensorMode irSensor
	SensorMode colorSensor
	Key escapeKey
	
	LED led
	Audio audio
	Power power
	
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
		pilot = new DifferentialPilot(WHEEL_DIAMETER, WHEEL_DISTANCE, leftRegMotor, rightRegMotor)
		scoopMotor = new Motor(new NXTRegulatedMotor(brick.getPort('A')))
		irSensor = new EV3IRSensor(brick.getPort('S2')).seekMode
		colorSensor = new EV3ColorSensor(brick.getPort('S3')).redMode
		escapeKey = brick.getKey('Escape')
		led = brick.LED
		audio = brick.audio
		name = brick.name
		this.channel = if(name == 'Xtend') 1 else 2
		scoopMotor.speed = scoopMotor.maxSpeed as int
		power = brick.power
	}
	
	override String getName() {
		name
	}
	
	override boolean isEscapePressed() {
		escapeKey.down
	}
	
	override OpponentPosition getOpponentPosition() {
		val sample = newFloatArrayOfSize(8)
		irSensor.fetchSample(sample, 0)
		val opponentIndex = (2-channel)*2
		return new OpponentPosition(sample.get(opponentIndex), sample.get(opponentIndex + 1))
	}
	
	override double getGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.fetchSample(sample, 0)
		return sample.get(0)
	}
	
	override void setSpeeds(double leftSpeed, double rightSpeed) {
		leftMotor.speed = (360 * abs(leftSpeed) / WHEEL_DIAMETER) as int 
		rightMotor.speed = (360 * abs(rightSpeed) / WHEEL_DIAMETER) as int
		if(leftSpeed < 0)
			leftMotor.backward
		else
			leftMotor.forward
		if(rightSpeed < 0)
			rightMotor.backward
		else
			rightMotor.forward
	}
	
	override void travelForward(double distance) {
		pilot.travel(distance, true)
	}
	
	override void travelBackward(double distance) {
		pilot.travel(-distance, true)
	}
	
	override void setTravelSpeed(double speed) {
		pilot.travelSpeed = speed
	}
	
	override double getTravelSpeed() {
		pilot.travelSpeed
	}
	
	override double getMaxTravelSpeed() {
		pilot.maxTravelSpeed
	}
	
	override void rotate(double angle) {
		pilot.rotate(angle, true)
	}
	
	override void setRotateSpeed(double speed) {
		pilot.rotateSpeed = rotateSpeed
	}
	
	override double getRotateSpeed() {
		pilot.rotateSpeed
	}
	
	override double getMaxRotateSpeed() {
		pilot.rotateMaxSpeed
	}
	
	override void curveForward(double radius, double angle) {
		if(angle < 0) 
			pilot.arc(-abs(radius), angle, true)
		else
			pilot.arc(abs(radius), angle, true)
	}
	
	override void curveBackward(double radius, double angle) {
		if(angle < 0)
			pilot.arc(abs(radius), angle, true)
		else
			pilot.arc(-abs(radius), angle, true)
	}
	
	override void curveTo(double angle, double distance) {
		val radius = 0.5 * distance * cos(0.5 * PI - angle.toRadians)
		curveForward(radius, angle)
	}
	
	override void stop() {
		pilot.stop
	}
	
	override void scoop(double angle) {
		scoopMotor.rotate(angle as int)
	}
	
	override void playSample(String fileName, int volume) {
		audio.playSample('samples/' + fileName + '.wav', volume)
	}	
	
	@NoAPI
	def void setLed(int pattern) {
		led.pattern = pattern
	}
	
	override double getBatteryState() {
		power.voltage / 9.0
	}
}