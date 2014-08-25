package org.xtext.xrobot

import lejos.hardware.motor.NXTRegulatedMotor
import org.xtext.xrobot.annotations.SimpleRMI

@SimpleRMI
class Motor {

	NXTRegulatedMotor motor

	new(NXTRegulatedMotor motor) {
		this.motor = motor
	}
	
	override void stop() {
		motor.stop
	}

	/**
	 * Set the motor into float mode. This will stop the motor without braking
	 * and the position of the motor will not be maintained.
	 */
	override void floatMode(boolean isFloat) {
		motor.flt(isFloat)
	}

	/**
	 * Wait until the current movement operation is complete (this can include
	 * the motor stalling).
	 */
	override void waitComplete() {
		motor.waitComplete
	}

	override void rotate(int angle) {
		motor.rotate(angle, true)
	}

	override int getTargetAngle() {
		motor.limitAngle
	}

	/**
	 * Set motor speed. As a rule of thumb 100 degrees per second are possible for each volt on an NXT motor. Therefore,
	 * disposable alkaline batteries can achieve a top speed of 900 deg/sec, while a rechargable lithium battery pack can achieve
	 * 740 deg/sec. 
	 * 
	 * @param speed in degrees per second.
	 */
	override void setSpeed(int speed) {
		motor.speed = speed
	}

	/**
	 * Returns the current motor speed.
	 *
	 * @return motor speed in degrees per second
	 */
	override int getSpeed() {
		motor.speed
	}

	/**
	 * Returns the maximim speed of the motor.
	 * 
	 * @return the maximum speed of the Motor in degrees per second.
	 */
	override double getMaxSpeed() {
		motor.maxSpeed
	}

	/**
	 * returns true if motor is stalled
	 * @return true if stalled
	 */
	override boolean isStalled() {
		motor.stalled
	}

	/**
	 * Set the required rate of acceleration degrees/s/s
	 * @param acceleration
	 */
	override void setAcceleration(int acceleration) {
		motor.acceleration = acceleration
	}

	/**
	 * Causes motor to rotate forward until <code>stop()</code> or <code>flt()</code> is called.
	 */
	override void forward() {
		motor.forward
	}

	/**
	 * Causes motor to rotate backwards until <code>stop()</code> or <code>flt()</code> is called.
	 */
	override void backward() {
		motor.backward
	}

	/**
	 * Return <code>true</code> if the motor is moving.
	 *
	 * @return <code>true</code> if the motor is currently in motion, <code>false</code> if stopped.
	 */
	override boolean isMoving() {
		motor.moving
	}

	/**
	 * Returns the tachometer count.
	 * 
	 * @return tachometer count in degrees
	 */
	override int getTachoCount() {
		motor.tachoCount
	}

	/**
	 * Reset the tachometer count.
	 */
	override void resetTachoCount() {
		motor.resetTachoCount
	}
}
