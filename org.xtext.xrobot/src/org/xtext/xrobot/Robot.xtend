package org.xtext.xrobot

import lejos.hardware.Audio
import lejos.hardware.Brick
import lejos.hardware.Key
import lejos.hardware.LED
import lejos.hardware.Power
import lejos.hardware.motor.NXTRegulatedMotor
import lejos.hardware.sensor.EV3ColorSensor
import lejos.hardware.sensor.SensorMode
import lejos.robotics.navigation.DifferentialPilot
import org.xtext.xrobot.annotations.Blocking
import org.xtext.xrobot.annotations.Calculated
import org.xtext.xrobot.annotations.NoAPI
import org.xtext.xrobot.annotations.SimpleRMI
import org.xtext.xrobot.annotations.SubComponent
import org.xtext.xrobot.annotations.Zombie
import org.xtext.xrobot.api.Direction
import org.xtext.xrobot.api.IRobotGeometry
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.util.LEDPatterns
import org.xtext.xrobot.util.SoundUtil
import org.xtext.xrobot.util.SystemSounds

import static extension java.lang.Math.*

@SimpleRMI
class Robot implements IRobotGeometry {

	RobotID robotID

	DifferentialPilot pilot

	SensorMode colorSensor

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
		colorSensor = new EV3ColorSensor(brick.getPort('S3')).redMode
		escapeKey = brick.getKey('Escape')
		led = brick.LED
		audio = brick.audio
		scoopMotor.speed = scoopMotor.maxSpeed as int
		power = brick.power
	}

	/**
	 * @return the robot identifier
	 */
	@NoAPI@Calculated
	def RobotID getRobotID() {
		robotID
	}
	
	/**
	 * @return true if the robot's escape button is currently pressed
	 */
	@NoAPI@Zombie
	def boolean isEscapePressed() {
		escapeKey.down
	}

	/**
	 * Returns the hue value of the ground color as measured by the color sensor.
	 * Use this to detect tilts or scan the ground for marks.
	 * 
	 * <p>This command is non-blocking, i.e. it returns immediately.</p>
	 * @return the hue value of the ground color as measured by the color sensor.
	 */
	override double getGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.fetchSample(sample, 0)
		sample.get(0)
	}

	/**
	 * Set both motors into motion with the given speed values in centimeters/second.
	 * If both speeds are positive, the robot moves forward. If they are negative, the robot
	 * moves backward. If one speed value is positive and the other is negative, the robot rotates.
	 * 
	 * <p>This command is non-blocking, i.e. it returns immediately and the motors 
	 * continue moving until they receive another command such as {@link #stop()}.</p>
	 * 
	 * <p>When the motors are started with two consecutive commands, the resulting movement
	 * may be inaccurate due to the delay between the commands. Therefore this command may
	 * be preferable in such situations, since it allows to start both motors with a single
	 * command.</p>
	 * 
	 * @param leftSpeed the speed of the left motor in centimeters/second   
	 * @param rightSpeed the speed of the right motor in centimeters/second   
	 */
	override void startMotors(double leftSpeed, double rightSpeed) {
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
	 * Move the robot forward or backward by {@code distance} centimeters at the current
	 * driving speed. The speed is set with {@link #setDrivingSpeed(double)}. If the distance
	 * is positive, the robot drives forward, otherwise it drives backward.
	 *  
	 * <p>This command blocks the current mode's execution until the movement is complete.
	 * Once finished, the motors are stopped.</p>
	 * 
	 * @param distance the distance in centimeters 
	 */
	@Blocking
	override void drive(double distance) {
		pilot.travel(distance, true)
	}

	/**
	 * Move the robot forward at the current driving speed until it is stopped.
	 * The speed is set with {@link #setDrivingSpeed(double)}.
	 * 
	 * <p>This command is <em>non-blocking</em>, i.e. it returns immediately and the motors
	 * continue moving until they receive another command such as {@link #stop()}.</p>
	 */
	override void driveForward() {
		pilot.forward
	}

	/**
	 * Move the robot backward at the current driving speed until it is stopped.
	 * The speed is set with {@link #setDrivingSpeed(double)}.
	 * 
	 * <p>This command is <em>non-blocking</em>, i.e. it returns immediately and the motors 
	 * continue moving until they receive another command such as {@link #stop()}.</p>
	 */
	override void driveBackward() {
		pilot.backward
	}

	/**
	 * Set the speed in centimeters/second for subsequent driving commands. This command
	 * does <em>not</em> initiate any movement.
	 * 
	 * <p>The following commands are affected by the driving speed:
	 * <ul>
	 *   <li>{@link #drive(double)}</li>
	 *   <li>{@link #driveForward()}</li>
	 *   <li>{@link #driveBackward()}</li>
	 * </ul>
	 * The maximal speed can be obtained with {@link #getMaxDrivingSpeed()}.
	 * The sign of the given speed value is ignored.</p>
	 * 
	 * @param the driving speed in centimeters/second
	 */
	override void setDrivingSpeed(double speed) {
		pilot.travelSpeed = abs(speed)
	}

	/**
	 * Return the currently set driving speed in centimeters/second. It can be modified
	 * using {@link #setDrivingSpeed(double)}.
	 * 
	 * @return the driving speed in centimeters/second 
	 */
	override double getDrivingSpeed() {
		pilot.travelSpeed
	}

	/**
	 * Return the maximal driving speed in centimeters/second. This value depends on the
	 * current status of the battery: faster movements are possible with a fresh battery.
	 * The maximal driving speed with a fully charged battery is approximately 30 cm/s. 
	 * 
	 * <p>The returned value can be used as a reference for {@link #setDrivingSpeed(double)}
	 * commands. For example, {@code drivingSpeed = 0.5 * maxDrivingSpeed} sets the speed
	 * to half of the maximal speed.</p>
	 * 
	 * @return the maximal driving speed in centimeters/second 
	 */
	override double getMaxDrivingSpeed() {
		pilot.maxTravelSpeed
	}

	/**
	 * Rotate the robot on the spot by {@code angle} degrees at the current rotation speed.
	 * The speed is set with {@link #setRotationSpeed(double)}. A positive angle means to
	 * rotate counter-clockwise (left), while a negative angle means to rotate clockwise (right).
	 * 
	 * <p>This command blocks the current mode's execution until the rotation is complete.
	 * Once finished, the motors are stopped.</p>
	 * 
	 * @param angle the rotation angle in degrees
	 */
	@Blocking
	override void rotate(double angle) {
		pilot.rotate(angle, true)
	}

	/**
	 * Rotate the robot counter-clockwise (left) at the current rotation speed until it
	 * is stopped. The speed is set with {@link #setRotationSpeed(double)}.
	 * 
	 * <p>This method is <em>non-blocking</em>, i.e. it returns immediately and the motors 
	 * continue moving until they receive another command such as {@link #stop()}.</p>
	 */
	override void rotateLeft() {
		pilot.rotateLeft
	}

	/**
	 * Rotate the robot clockwise (right) at the current rotation speed until it is stopped.
	 * The speed is set with {@link #setRotationSpeed(double)}.
	 * 
	 * <p>This method is <em>non-blocking</em>, i.e. it returns immediately and the motors 
	 * continue moving until they receive another command such as {@link #stop()}.</p>
	 */
	override void rotateRight() {
		pilot.rotateRight
	}

	/**
	 * Set the speed in degrees/second for subsequent rotation commands. This command does
	 * <em>not</em> initiate any movement.
	 * 
	 * <p>The following commands are affected by the rotation speed:
	 * <ul>
	 *   <li>{@link #rotate(double)}</li>
	 *   <li>{@link #rotateLeft()}</li>
	 *   <li>{@link #rotateRight()}</li>
	 * </ul>
	 * The maximal speed can be obtained with {@link #getMaxRotationSpeed()}.
	 * The sign of the given speed value is ignored.</p>
	 * 
	 * @param the rotation speed in degrees/second
	 */
	override void setRotationSpeed(double rotationSpeed) {
		pilot.rotateSpeed = abs(rotationSpeed)
	}

	/**
	 * Return the currently set rotation speed in degrees/second. It can be modified
	 * using {@link #setRotationSpeed(double)}.
	 * 
	 * @return the rotation speed in degrees/second 
	 */
	override double getRotationSpeed() {
		pilot.rotateSpeed
	}

	/**
	 * Return the maximal rotation speed in degrees/second. This value depends on the
	 * current status of the battery: faster movements are possible with a fresh battery.
	 * The maximal rotation speed with a fully charged battery is approximately 360 &deg;/s. 
	 * 
	 * <p>The returned value can be used as a reference for {@link #setRotationSpeed(double)}
	 * commands. For example, {@code rotationSpeed = 0.5 * maxRotationSpeed} sets the speed
	 * to half of the maximal speed.</p>
	 * 
	 * @return the maximal rotation speed in degrees/second 
	 */
	override double getMaxRotationSpeed() {
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
	 * Let the robot travel a backward curve following a segment with the given {@code angle}
	 * of a circle with the given {@code radius}.
	 * 
	 * A positive angle means a clockwise curve (left), while a negative angle means a
	 * counter-clockwise curve (right). The sign of the radius is ignored.
	 */
	@Blocking
	override void curveBackward(double radius, double angle) {
		if (angle < 0)
			pilot.arc(-abs(radius), -angle, true)
		else
			pilot.arc(abs(radius), -angle, true)
	}

	/**
	 * Let the robot travel a forward curve to the point with the relative polar
	 * coordinates <code>angle</code> and <code>distance</code>.
	 */
	@Blocking
	override void curveTo(double distance, double angle) {
		if(abs(angle) < 1) {
			drive(distance)
		} else if(abs(abs(angle) - 180) < 1) {
			drive(-distance)
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
	 * Stop all motors immediately.
	 */
	override void stop() {
		pilot.stop
	}

	/**
     * Reset the robot: 
     * Left and right motors are stopped,
     * scoop is moved to neutral position, 
     * and speeds are set to maximal values.
     */
	override void reset() {
		stop
		scoop(0)
		drivingSpeed = maxDrivingSpeed
		rotationSpeed = maxRotationSpeed
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
