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
import org.xtext.xrobot.annotations.Blocking
import org.xtext.xrobot.annotations.Calculated
import org.xtext.xrobot.annotations.NoAPI
import org.xtext.xrobot.annotations.SimpleRMI
import org.xtext.xrobot.annotations.SubComponent
import org.xtext.xrobot.api.RobotSight
import org.xtext.xrobot.util.SoundUtil

import static extension java.lang.Math.*
import org.xtext.xrobot.api.IRobotGeometry

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
	
	/**
	 * @return the robot's name
	 */
	override String getName() {
		name
	}
	
	@NoAPI
	def boolean isEscapePressed() {
		escapeKey.down
	}
	
	@NoAPI
	def OpponentPosition getOpponentPosition() {
		val sample = newFloatArrayOfSize(8)
		irSensor.fetchSample(sample, 0)
		return new OpponentPosition(sample, channel)
	}
	
	@Calculated
	override RobotSight getRobotSight() {
		null	
	}
	
	/**
	 * @returns the measured ground color between 0.0 and 1.0
	 */
	override double getGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.fetchSample(sample, 0)
		return sample.get(0)
	}
	
	/**
	 * Sets both motors in motion simultaneously. 
	 * 
	 * Speed values are in degrees/second, Negative values will move the motor backward.
	 * This method is non-blocking, i.e. the motors will continue moving until they 
	 * receive another command.
	 * 
	 * @param leftSpeed the speed of the left motor in degrees/second   
	 * @param rightSpeed the speed of the right motor in degrees/second   
	 */
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
	
	/**
	 * Moves the robot forward by <code>distance</code> centimeters.
	 * 
	 * This method will block the current mode's execution until the move is complete.
	 * Once finished, the motors will be stopped.
	 * 
	 * @param distance the distance in centimeters 
	 */
	@Blocking
	override void forward(double distance) {
		pilot.travel(distance, true)
	}
	
	/**
	 * Moves the robot backward by <code>distance</code> centimeters.
	 * 
	 * This method will block the current mode's execution until the move is complete.
	 * Once finished, the motors will be stopped.
	 * 
	 * @param distance the distance in centimeters 
	 */
	@Blocking
	override void backward(double distance) {
		pilot.travel(-distance, true)
	}
	
	/**
	 * Sets the speed in centimeter/second for all {@link #forward()} and {@link #backward()} 
	 * commands. Does not actually mode the robot.
	 * 
	 * @param the speed in centimeter/second 
	 */
	override void setTravelSpeed(double speed) {
		pilot.travelSpeed = speed
	}
	
	/**
	 * Returns the speed for all {@link #forward()} and {@link #backward()} commands.
	 * 
	 * @return the speed in centimeter/second 
	 */
	override double getTravelSpeed() {
		pilot.travelSpeed
	}
	
	/**
	 * Returns the maximum speed for {@link #forward()} and {@link #backward()} commands
	 * depending on the battery status.
	 * 
	 * @return the speed in centimeter/second 
	 */
	override double getMaxTravelSpeed() {
		pilot.maxTravelSpeed
	}
	
	/** 
	 * Rotates the robot on the spot by <code>angle</code> degrees.
	 * 
	 * This method will block the current mode's execution until the move is complete.
	 * Once finished, the motors will be stopped.
	 * 
	 */
	@Blocking
	override void rotate(double angle) {
		pilot.rotate(angle, true)
	}
	
	/**
	 * Sets the speed in degrees/second for all {@link #rotate()} commands. Does not 
	 * actually mode the robot.
	 * 
	 * @param the speed in centimeter/second 
	 */
	override void setRotateSpeed(double speed) {
		pilot.rotateSpeed = rotateSpeed
	}
	
	override double getRotateSpeed() {
		pilot.rotateSpeed
	}
	
	override double getMaxRotateSpeed() {
		pilot.rotateMaxSpeed
	}
	
	@Blocking
	override void curveForward(double radius, double angle) {
		if(angle < 0) 
			pilot.arc(-abs(radius), angle, true)
		else
			pilot.arc(abs(radius), angle, true)
	}
	
	@Blocking
	override void curveBackward(double radius, double angle) {
		if(angle < 0)
			pilot.arc(abs(radius), angle, true)
		else
			pilot.arc(-abs(radius), angle, true)
	}
	
	@Blocking
	override void curveTo(double angle, double distance) {
		val radius = 0.5 * distance * cos(0.5 * PI - angle.toRadians)
		curveForward(radius, angle)
	}
	
	override boolean isMoving() {
		pilot.isMoving
	}
	
	override void stop() {
		pilot.stop
	}
	
	@Blocking
	override void scoop(double angle) {
		scoopMotor.rotateTo(angle as int)
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
	
	@Calculated
	override void update() {
	}
}