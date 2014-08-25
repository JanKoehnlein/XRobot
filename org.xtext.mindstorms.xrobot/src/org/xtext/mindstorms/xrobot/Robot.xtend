package org.xtext.mindstorms.xrobot

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
import org.xtext.mindstorms.xrobot.annotations.NoAPI
import org.xtext.mindstorms.xrobot.annotations.SimpleRMI
import org.xtext.mindstorms.xrobot.annotations.SubComponent
import org.xtext.mindstorms.xrobot.util.SoundUtil

import static extension java.lang.Math.*

@SimpleRMI
class Robot {
	
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
		pilot = new DifferentialPilot(4.32, 9.50, leftRegMotor, rightRegMotor)
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
	
	override void forward(double distance) {
		pilot.travel(distance, true)
	}
	
	override void backward(double distance) {
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
		pilot.arc(radius, angle, true)
	}
	
	override void curveBackward(double radius, double angle) {
		pilot.arc(radius, -angle, true)
	}
	
	override void curveTo(double angle, double distance) {
		val radius = 0.5 * distance * cos(0.5 * PI - angle.toRadians)
		curveForward(radius, angle)
	}
	
	override void waitComplete() {
		leftMotor.waitComplete
		rightMotor.waitComplete
		scoopMotor.waitComplete
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
	
	@NoAPI 
	def double getBatteryState() {
		power.voltage / 9.0
	}
}