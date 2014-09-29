package org.xtext.xrobot

import lejos.hardware.Audio
import lejos.hardware.Brick
import lejos.hardware.Key
import lejos.hardware.LED
import lejos.hardware.Power
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.xrobot.annotations.Blocking
import org.xtext.xrobot.annotations.Calculated
import org.xtext.xrobot.annotations.NoAPI
import org.xtext.xrobot.annotations.SimpleRMI
import org.xtext.xrobot.annotations.SubComponent
import org.xtext.xrobot.api.Direction
import org.xtext.xrobot.api.IRobotGeometry
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.util.LEDPatterns
import org.xtext.xrobot.util.SoundUtil
import org.xtext.xrobot.util.SystemSounds

import static extension java.lang.Math.*
import org.xtext.xrobot.annotations.Zombie

@SimpleRMI
class Robot implements IRobotGeometry {

	RobotID robotID

	DifferentialPilot pilot

	Key escapeKey

	LED led
	Audio audio
	Power power

	extension SoundUtil = new SoundUtil

	@SubComponent Motor leftMotor
	@SubComponent Motor rightMotor
	@SubComponent Motor scoopMotor

	new(Brick brick) {
		robotID = RobotID.valueOf(brick.name)
		val leftRegMotor = new NXTRegulatedMotor(brick.getPort('B'))
		val rightRegMotor = new NXTRegulatedMotor(brick.getPort('C'))
		leftMotor = new Motor(leftRegMotor)
		rightMotor = new Motor(rightRegMotor)
		pilot = new DifferentialPilot(WHEEL_DIAMETER, WHEEL_DISTANCE, leftRegMotor, rightRegMotor)
		scoopMotor = new Motor(new NXTRegulatedMotor(brick.getPort('A')))
		escapeKey = brick.getKey('Escape')
		led = brick.LED
		audio = brick.audio
		scoopMotor.speed = scoopMotor.maxSpeed as int
		power = brick.power
	}

	@NoAPI@Calculated
	def RobotID getRobotID() {
		robotID
	}
	
	@NoAPI@Zombie
	def boolean isEscapePressed() {
		escapeKey.down
	}

	/**
	 * Sets both motors in motion simultaneously. 
	 * 
	 * Speed values are in degrees/second, Negative values will move the motor backward.
	 * 
	 * This method is non-blocking, i.e. it returns immediately and the motors will 
	 * continue moving until they receive another command.
	 * 
	 * @param leftSpeed the speed of the left motor in degrees/second   
	 * @param rightSpeed the speed of the right motor in degrees/second   
	 */
	override void setSpeeds(double leftSpeed, double rightSpeed) {
		leftMotor.speed = (360 * abs(leftSpeed) / WHEEL_DIAMETER) as int
		rightMotor.speed = (360 * abs(rightSpeed) / WHEEL_DIAMETER) as int
		if (leftSpeed < 0)
			leftMotor.backward
		else
			leftMotor.forward
		if (rightSpeed < 0)
			rightMotor.backward
		else
			rightMotor.forward
	}

	/**
	 * Moves the robot forward by <code>distance</code> centimeters at the current travel speed.
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
	 * Moves the robot forward at the current travel speed.
	 * 
	 * This method is non-blocking, i.e. it returns immediately and the motors will 
	 * continue moving until they receive another command.
	 * 
	 * @param distance the distance in centimeters 
	 */
	override void forward() {
		pilot.forward
	}

	/**
	 * Moves the robot backward by <code>distance</code> centimeters at the current travel speed.
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
	 * Moves the robot backward at the current travel speed.
	 * 
	 * This method is non-blocking, i.e. it returns immediately and the motors will 
	 * continue moving until they receive another command.
	 * 
	 * @param distance the distance in centimeters 
	 */
	override void backward() {
		pilot.backward
	}

	/**
	 * Sets the speed in centimeters/second for all {@link #forward()} and {@link #backward()} 
	 * commands. Does not actually mode the robot.
	 * 
	 * @param the speed in centimeters/second 
	 */
	override void setTravelSpeed(double speed) {
		pilot.travelSpeed = speed
	}

	/**
	 * Returns the speed for all {@link #forward()} and {@link #backward()} commands.
	 * 
	 * @return the speed in centimeters/second 
	 */
	override double getTravelSpeed() {
		pilot.travelSpeed
	}

	/**
	 * Returns the maximum speed for {@link #forward()} and {@link #backward()} commands
	 * depending on the battery status.
	 * 
	 * @return the speed in centimeters/second 
	 */
	override double getMaxTravelSpeed() {
		pilot.maxTravelSpeed
	}

	/**
	 * Rotate the robot on the spot by <code>angle</code> degrees at the current rotation
	 * speed. A positive angle means to rotate counter-clockwise (left), while a negative
	 * angle means to rotate clockwise (right).
	 * 
	 * This method blocks the current mode's execution until the move is complete.
	 * Once finished, the motors are stopped.
	 */
	@Blocking
	override void rotate(double angle) {
		pilot.rotate(angle, true)
	}

	/**
	 * Rotate the robot counter-clockwise (left) on the spot at the current rotation speed.
	 * 
	 * This method is non-blocking, i.e. it returns immediately and the motors will 
	 * continue moving until they receive another command.
	 */
	override void rotateLeft() {
		pilot.rotateLeft
	}

	/**
	 * Rotate the robot clockwise (right) on the spot at the current rotation speed.
	 * 
	 * This method is non-blocking, i.e. it returns immediately and the motors will 
	 * continue moving until they receive another command.
	 */
	override void rotateRight() {
		pilot.rotateRight
	}

	/**
	 * Set the speed for all {@link #rotate(double)}, {@link #rotateLeft()} and
	 * {@link #rotateRight()} commands. Does not actually move the robot.
	 * 
	 * @param the rotation speed in degrees/second
	 */
	override void setRotateSpeed(double rotateSpeed) {
		pilot.rotateSpeed = rotateSpeed
	}

	/**
	 * Returns the speed for all {@link #rotate(double)}, {@link #rotateLeft()} and
	 * {@link #rotateRight()} commands.
	 * 
	 * @return the rotate speed in degrees/second 
	 */
	override double getRotateSpeed() {
		pilot.rotateSpeed
	}

	/**
	 * Returns the maximum speed for all {@link #rotate(double)}, {@link #rotateLeft()} and
	 * {@link #rotateRight()} commands depending on the battery status.
	 * 
	 * @return the rotation speed in degrees/second 
	 */
	override double getMaxRotateSpeed() {
		pilot.rotateMaxSpeed
	}

	/**
	 * Let the robot travel a forward curve following a segment with the given {@code angle}
	 * of a circle with the given {@code radius}.
	 * 
	 * A positive angle means a counter-clockwise curve (left), while a negative angle
	 * means a clockwise curve (right). The sign of the radius is ignored.
	 * 
	 * @param radius
	 * 		The radius of the circle on which to travel
	 * @param angle
	 * 		The angle of the circle segment that is actually covered
	 */
	@Blocking
	override void curveForward(double radius, double angle) {
		if (angle < 0)
			pilot.arc(-abs(radius), angle, true)
		else
			pilot.arc(abs(radius), angle, true)
	}

	/**
	 * Lets the robot travel a backward curve with the given <code>radius</code> and 
	 * <code>angle</code>.
	 * 
	 * A positive angle means a clockwise curve (left), while a negative angle means a
	 * counter-clockwise curve (right). The sign of the radius is ignored.
	 */
	@Blocking
	override void curveBackward(double radius, double angle) {
		if (angle < 0)
			pilot.arc(abs(radius), -angle, true)
		else
			pilot.arc(-abs(radius), -angle, true)
	}

	/**
	 * Lets the robot travel a forward curve to the point with the relative polar
	 * coordinates <code>angle</code> and <code>distance</code>.
	 */
	@Blocking
	override void curveTo(double distance, double angle) {
		if(abs(angle) < 1) {
			forward(distance)
		} else if(abs(abs(angle) - 180) < 1) {
			backward(distance)
		} else {
			val radius = 0.5 * distance / sin(angle.toRadians)
			curveForward(radius, 2 * angle)
		}
	}

	/**
	 * @return true if any of the motors is moving. 
	 */
	override boolean isMoving() {
		pilot.isMoving
	}

	/**
	 * Stops all motors immediately.
	 */
	override void stop() {
		pilot.stop
	}

	/**
     * Resets the robot.
     * 
     * Left and right motors is stopped. 
     * Scoop is moved to neutral position. 
     * Speeds are set to max.
     */
	override void reset() {
		stop
		scoop(0)
		travelSpeed = maxTravelSpeed
		rotateSpeed = maxRotateSpeed
		lastExecutedCommandSerialNr = -1
	}

	/**
	 * Moves the robot's scoop. Values are truncated to be between -1.0 and 1.0 
	 * 0 is on the floor
	 * 1 is completely up
	 * -1 is completely down (could roll the robot over)   
	 * 
	 * This method will block the current mode's execution until the move is complete.
	 * Once finished, the motors will be stopped.
	 */
	@Blocking('getScoopMoving')
	override void scoop(double angle) {
		val intAngle = (min(1, max(angle, -1)) * 200) as int
		scoopMotor.rotateTo(intAngle)
	}

	@NoAPI
	def boolean isScoopMoving() {
		scoopMotor.isMoving	
	} 
	
	override void playSample(String fileName) {
		audio.playSample('samples/' + fileName + '.wav', 100)
	}

	/**
	 * @see {@link SystemSounds} for values
	 */
	@NoAPI@Zombie
	def void systemSound(int sound) {
		audio.systemSound(sound)
	}

	/** 
	 * @see {@link LEDPatterns} for values 
	 */
	@NoAPI@Zombie
	def void setLed(int pattern) {
		led.pattern = pattern
	}

	/**
	 * @returns the battery's charging state between 0.0 and 1.0
	 */
	@NoAPI@Zombie
	def double getBatteryState() {
		power.voltage / 8.1
	}

	/**
	 * Updates this robot with the latest sensor data and robot state. 
	 * 
	 * The state is usually only updated when the modes' conditions are checked. 
	 * A new mode is entered with exactly that state to make sure the condition still holds.
	 * Use this method if you need fresh data during a mode's execution.
	 */
	@Calculated
	override void update() {
		// implement on the server only		
	}

	/**
	 * @return the robot's position.
	 */
	@Calculated
	override RobotPosition getOwnPosition() {
	}

	/**
	 * @return the opponent's position.
	 */
	@Calculated
	override RobotPosition getOpponentPosition() {
	}

	/**
	 * @return the opponent's direction.
	 */
	@Calculated
	override Direction getOpponentDirection() {
	}

	/**
	 * @return the center direction.
	 */
	@Calculated
	override Direction getCenterDirection() {
	}
	
}
