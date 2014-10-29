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
import org.xtext.xrobot.annotations.Zombie
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.api.Sample
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.util.LEDPatterns
import org.xtext.xrobot.util.SystemSounds

import static extension java.lang.Math.*
import static extension org.xtext.xrobot.api.GeometryExtensions.*

// The following JavaDoc goes into the derived IRobot interface
/**
 * The interface to interact with your robot.
 * 
 * <p>An instance of {@link IRobot} is globally bound to the <code>this</code> 
 * variable in your script, such that all methods can be called directly at
 * all locations.</p>
 * 
 * <p>This interface defines methods to steer the robot, to read its state, to
 * use its sensors, to access positions, and to play audio.</p>
 * 
 * <p>
 * There are two variants of movement methods: blocking and non-blocking. 
 * Non-blocking methods start a move and return immediately. They do not 
 * define a target where the move should stop. Instead, the move continues 
 * until another move method is called or the game is over.
 * On the other hand, blocking methods define a target of the move. They 
 * will not move the robot beyond this target, and they do not return 
 * until the target is reached. This allows to build exact maneuvers without 
 * using timers. If the robot is performing a blocking move while the current 
 * mode is canceled and the next mode calls a move method, the move is 
 * interrupted even if the target has not been reached. If not interrupted, 
 * the move will be finished.
 * </p>
 */
@SimpleRMI
class Robot {
	
	/**
	 * The total length of the robot in centimeters including its scoop.
	 * Value is 25&nbsp;cm.
	 */
	public static val ROBOT_LENGTH = 25.0

	/**
	 * The total width of the robot in centimeters.
	 * Value is 12&nbsp;cm.
	 */
	public static val ROBOT_WIDTH = 12.0
	
	/**
	 * The total height of the robot in centimeters.
	 * Value is 23.8&nbsp;cm.
	 */
	public static val ROBOT_HEIGHT = 23.8
	
	/**
	 * The diameter of the robot's wheels in centimeters.
	 * Value is 4.32&nbsp;cm.
	 */
	public static val ROBOT_WHEEL_DIAMETER = 4.32

	/**
	 * The robot's track width (distance of wheels) in centimeters.
	 * Value is 9.5&nbsp;cm.
	 */
	public static val ROBOT_WHEEL_DISTANCE = 9.5
	
	/**
	 * The length of the robot's scoop (only the part that extends beyond the front
	 * of the robot).
	 * Value is 11.5&nbsp;cm.
	 */
	public static val ROBOT_SCOOP_LENGTH = 11.5
	
	/**
	 * The distance in centimeters between the robot's axis and the fiducial marker.
	 * Value is 4&nbsp;cm.
	 */
	public static val ROBOT_MARKER_OFFSET = 4.0
	
	/**
	 * The distance in centimeters between the robot's axis and the back of the robot.
	 * Value is 4.5&nbsp;cm.
	 */
	public static val ROBOT_AXIS_OFFSET = 4.5
	
	/**
	 * The radius of the outer edge of the boundary of the arena in centimeters.
	 * Value is 60&nbsp;cm.
	 */
	public static val ARENA_OUTER_RADIUS = 60.0
	
	/**
	 * The radius of the inner edge of the boundary of the arena in centimeters. 
	 * Make sure you don't cross this edge, or you risk losing the game!
	 * Value is 55&nbsp;cm.
	 */
	public static val ARENA_INNER_RADIUS = 55.0
	
	/**
	 * The threshold of the brightness value at which a game-over situation is detected.
	 */
	static val GAME_OVER_THRESHOLD = 0.035
	
	/**
	 * The voltage of the battery pack when it is full.
	 */
	static val FULL_BATTERY_VOLTAGE = 8.1
	
	/**
	 * The minimal time in milliseconds where {@link #isMoving()} returns true after a blocking
	 * movement command has been called.
	 */
	static val MIN_MOVE_DELAY = 20

	RobotID robotID

	DifferentialPilot pilot
	long lastMoveTime

	SensorMode colorSensor
	double lastColorSample

	Key escapeKey
	LED led
	Audio audio
	Power power
	
	boolean isDead
	boolean isInvincible
	
	NXTRegulatedMotor leftMotor
	NXTRegulatedMotor rightMotor
	NXTRegulatedMotor scoopMotor

	new(Brick brick) {
		robotID = RobotID.valueOf(brick.name)
		leftMotor = new NXTRegulatedMotor(brick.getPort('B'))
		rightMotor = new NXTRegulatedMotor(brick.getPort('C'))
		pilot = new DifferentialPilot(ROBOT_WHEEL_DIAMETER, ROBOT_WHEEL_DISTANCE, leftMotor, rightMotor)
		scoopMotor = new NXTRegulatedMotor(brick.getPort('A'))
		colorSensor = new EV3ColorSensor(brick.getPort('S3')).redMode
		escapeKey = brick.getKey('Escape')
		led = brick.LED
		audio = brick.audio
		scoopMotor.speed = scoopMotor.maxSpeed as int
		power = brick.power
		lastColorSample = 1.0
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
	 * Returns the brightness value of the ground color as measured by the color sensor.
	 * Use this to detect tilts or scan the ground for marks.
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * <p>This command is <em>non-blocking</em>, i.e. it returns immediately.</p>
	 * 
	 * @return the brightness value of the ground color as measured by the color sensor
	 */
	override double getGroundColor() {
		val sample = newFloatArrayOfSize(1)
		colorSensor.fetchSample(sample, 0)
		lastColorSample = sample.get(0)
		return lastColorSample
	}

	/**
	 * Set both motors into motion with the given speed values in centimeters/second.
	 * If both speeds are positive, the robot moves forward. If they are negative, the robot
	 * moves backward. If one speed value is positive and the other is negative, the robot rotates 
	 * or drives a curve.
	 * 
	 * <p>This command is <em>non-blocking</em>, i.e. it returns immediately and the motors 
	 * continue moving until they receive another command such as {@link #stop()}.</p>
	 *  
	 * @param leftSpeed the speed of the left motor in centimeters/second   
	 * @param rightSpeed the speed of the right motor in centimeters/second   
	 */
	override void startMotors(double leftSpeed, double rightSpeed) {
		leftMotor.speed = (360 * leftSpeed / ROBOT_WHEEL_DIAMETER) as int
		rightMotor.speed = (360 * rightSpeed / ROBOT_WHEEL_DIAMETER) as int
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
		updateMoveTime
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
	 *   <li>{@link #curveForward(double, double)}</li>
	 *   <li>{@link #curveBackward(double, double)}</li>
	 *   <li>{@link #curveTo(double, double)}</li>
	 * </ul>
	 * The maximal speed can be obtained with {@link #getMaxDrivingSpeed()}.
	 * The sign of the given speed value is ignored.</p>
	 * 
	 * @param speed the driving speed in centimeters/second
	 */
	override void setDrivingSpeed(double speed) {
		pilot.travelSpeed = abs(speed)
	}

	/**
	 * Return the currently set driving speed in centimeters/second. It can be modified
	 * using {@link #setDrivingSpeed(double)}.
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * @return the driving speed in centimeters/second 
	 */
	override double getDrivingSpeed() {
		pilot.travelSpeed
	}

	/**
	 * Return the maximal driving speed in centimeters/second. This value depends on the
	 * current status of the battery: faster movements are possible with a fresh battery.
	 * The maximal driving speed with a fully charged battery is approximately 30cm/s. 
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
		updateMoveTime
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
	 * @param rotationSpeed the rotation speed in degrees/second
	 */
	override void setRotationSpeed(double rotationSpeed) {
		pilot.rotateSpeed = abs(rotationSpeed)
	}

	/**
	 * Return the currently set rotation speed in degrees/second. It can be modified
	 * using {@link #setRotationSpeed(double)}.
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
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
	 * in degrees of a circle with the given {@code radius} in centimeters.
	 * A positive angle means a counter-clockwise curve (left), while a negative angle
	 * means a clockwise curve (right). The sign of the radius is ignored.
	 * The speed of this movement is set with {@link #setDrivingSpeed(double)}.
	 * 
	 * <p>This command blocks the current mode's execution until the rotation is complete.
	 * Once finished, the motors are stopped.</p>
	 * 
	 * @param radius
	 * 		The radius in centimeters of the circle on which to travel
	 * @param angle
	 * 		The angle in degrees of the circle segment that is actually covered
	 */
	@Blocking
	override void curveForward(double radius, double angle) {
		if (angle < 0)
			pilot.arc(-abs(radius), angle, true)
		else
			pilot.arc(abs(radius), angle, true)
		updateMoveTime
	}

	/**
	 * Let the robot travel a backward curve following a segment with the given {@code angle}
	 * in degrees of a circle with the given {@code radius} in centimeters.
	 * A positive angle means a clockwise curve (left), while a negative angle means a
	 * counter-clockwise curve (right). The sign of the radius is ignored.
	 * The speed of this movement is set with {@link #setDrivingSpeed(double)}.
	 *
	 * <p>This command blocks the current mode's execution until the rotation is complete.
	 * Once finished, the motors are stopped.</p>
	 * 
	 * @param radius
	 * 		The radius in centimeters of the circle on which to travel
	 * @param angle
	 * 		The angle in degrees of the circle segment that is actually covered
	 */
	@Blocking
	override void curveBackward(double radius, double angle) {
		if (angle < 0)
			pilot.arc(-abs(radius), -angle, true)
		else
			pilot.arc(abs(radius), -angle, true)
		updateMoveTime
	}

	/**
	 * Let the robot travel a forward curve to the point with the polar
	 * coordinates {@code angle} in degrees and {@code distance} in centimeters.
	 * You can directly use the values returned by {@link #getOpponentBearing()} or
	 * {@link #getCenterBearing()} to drive a curve to the opponent resp. center. 
	 * 
	 * <p>
	 * The following picture illustrates the curve: The own position is the blue marker. 
	 * The arrow points into the view direction. The angle <code>a</code> and the distance 
	 * <code>d</code> define the target point. The curve is the section of the circle that 
	 * connects both points and is tangent to the view vector.
	 * </p>
	 * 
	 * <p><img src="doc-files/CurveTo.png" width="375"/></p>
	 * 
	 * <p>
	 * The angle is normalized to be between -180 and 180 degrees. If the 
	 * <code>angle</code> is close to 0&deg; the robot will drive <code>distance</code> 
	 * centimeters forward, close to +/-180&deg; backward. A positive angle means a 
	 * counter-clockwise curve (left), while a negative angle means a clockwise curve (right).
	 * Note that the curve can leave the arena when the angle's absolute value is to large.
	 * </p>
	 * 
	 * <p>
	 * The speed of this movement is set with {@link #setDrivingSpeed(double)}.
	 * </p>
	 * 
	 * <p>This command blocks the current mode's execution until the rotation is complete.
	 * Once finished, the motors are stopped.</p>
	 * 
	 * @param distance
	 * 		The distance in centimeters of the targeted point from the robot's current position
	 * @param angle
	 * 		The angle in degrees of the targeted point relative to the robot's view direction. 
	 * 		It will be normalized to be between -180 and 180 degrees.
	 */
	@Blocking
	override void curveTo(double distance, double angle) {
		val a = angle.minimizeAngle
		if(abs(a) < 1) {
			drive(distance)
		} else if(abs(abs(a) - 180) < 1) {
			drive(-distance)
		} else {
			val radius = 0.5 * distance / sin(a.toRadians)
			curveForward(radius, 2 * a)
		}
		updateMoveTime
	}
	
	/**
	 * Update the timestamp of the last blocking movement command.
	 */
	private def void updateMoveTime() {
		lastMoveTime = System.currentTimeMillis
	}

	/**
	 * Determine whether the robot is currently executing a movement command.
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * @return true if any of the motors is moving
	 */
	override boolean isMoving() {
		val time = System.currentTimeMillis
		if (time - lastMoveTime < MIN_MOVE_DELAY)
			true
		else
			pilot.isMoving
	}

	/**
	 * Stop all motors immediately. Any previously given movement command is aborted.
	 */
	@Zombie
	override void stop() {
		pilot.quickStop
		lastMoveTime = 0
	}

	/**
     * Reset the robot to its starting state: left and right motors are stopped,
     * scoop is moved to neutral position, and speeds are set to maximal values.
     * If the robot is dead, it is resurrected.
     */
    @NoAPI@Zombie
	def void reset() {
		stop
		isDead = false
		scoop(0)
		drivingSpeed = maxDrivingSpeed
		rotationSpeed = maxRotationSpeed
		lastExecutedCommandSerialNr = -1
	}

	/**
	 * Move the robot's scoop to the specified position.
	 * 
	 * <p>
	 * Values are
	 * <ul>
	 * <li>0 is on the floor (the starting position),</li>
	 * <li>1 is completely up, and</li>
	 * <li>-1 is completely down (could roll the robot over).</li>
	 * </ul>
	 * Values below -1 or above 1 are truncated to these limits.   
	 * </p>
	 * 
	 * <p>This command is <em>non-blocking</em>, in the sense that it returns immediately 
	 * and the scoop motor continues moving until it reaches the specified position. But
	 * if another scoop command is given, it is blocked until the first command has finished 
	 * its movement.</p>
	 * 
	 * @param position
	 * 		The target position of the robot's scoop (between -1 and +1)
	 */
	@Blocking('getScoopMoving')
	override void scoop(double position) {
		val intAngle = (min(1, max(position, -1)) * 200) as int
		scoopMotor.rotateTo(intAngle)
	}

	/**
	 * @return true if the scoop motor is currently moving
	 */
	@NoAPI
	def boolean isScoopMoving() {
		scoopMotor.isMoving	
	}
	
	/**
	 * Play one of the predefined audio samples (see {@link Sample}).
	 * 
	 * @param sample
	 * 		A reference to a predefined sample
	 */
	@Calculated
	override void play(Sample sample) {
	}

	/**
	 * Let the robot say a line of text.
	 * 
	 * @param text
	 * 		A text that shall be spoken by the robot
	 */
	@Calculated 
	override void say(String text) {
	}

	/**
	 * Wait for the specified number of milliseconds before executing the next command.
	 * Non-blocking commands that have been executed earlier may still continue.
	 * Negative values are treated as zero.
	 * 
	 * @param milliseconds
	 * 		The number of milliseconds to wait
	 */	
	@Calculated
	override void sleep(int milliseconds) {
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
		power.voltage / FULL_BATTERY_VOLTAGE
	}
	
	/**
	 * Check whether the robot has died. This happens when it crosses the boundary of
	 * the arena or when it tilts over.
	 */
	@NoAPI@Zombie
	def boolean isDead() {
		if(!isDead && !isInvincible) {
			// When the robot tilts over, its color sensor cannot receive any reflections,
			// so the reported color value is 0.
			isDead = lastColorSample < GAME_OVER_THRESHOLD
			if (isDead && isMoving) {
				// Emergency brake!
				pilot.quickStop
			}
		}
		return isDead
	}
	
	/**
	 * Set the invincible status of the robot. When the robot is invincible, it cannot die,
	 * thus {@link #isDead()} always returns {@code false}.
	 */
	@NoAPI@Zombie
	def void setInvincible(boolean invincible) {
		this.isInvincible = invincible
		if (invincible) {
			isDead = false
		}
	}

	/**
	 * Update the robot with the latest sensor data and robot state. 
	 * 
	 * <p>
	 * The state is usually only updated when the modes' conditions are checked. 
	 * A new mode is entered with exactly that state to make sure the condition still holds.
	 * Use this method if you need fresh data during a mode's execution.
	 * </p>
	 * 
	 * <p>The following commands are affected by state updates:
	 * <ul>
	 *   <li>{@link #getCenterBearing()}</li>
	 *   <li>{@link #getDrivingSpeed()}</li>
	 *   <li>{@link #getGroundColor()}</li>
	 *   <li>{@link #getMaxDrivingSpeed()}</li>
	 *   <li>{@link #getMaxRotationSpeed()}</li>
	 *   <li>{@link #getOpponentBearing()}</li>
	 *   <li>{@link #getOpponentPosition()}</li>
	 *   <li>{@link #getOwnPosition()}</li>
	 *   <li>{@link #getRotationSpeed()}</li>
	 *   <li>{@link #isMoving()}</li>
	 * </ul></p>
	 */
	@Calculated
	override void update() {
		// implement on the server only		
	}

	/**
	 * Get the current absolute position of the robot. This includes (x,y) coordinates in
	 * centimeters and the view direction in degrees. 
	 * 
	 * <p>The coordinates are relative to the center of the arena in a right handed coordinate
	 * system. The view direction ranges from -180&deg; to 180&deg; and is relative to the 
	 * x-axis. A positive view direction means the robot is looking into the positive 
	 * y-direction. The value denotes the center of the robot's rear axle.</p>
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * @return the robot's current absolute position
	 */
	@Calculated
	override RobotPosition getOwnPosition() {
	}

	/**
	 * Get the current absolute position of your opponent. This includes x- and y-coordinates in
	 * centimeters and the view direction in degrees. 
	 * 
	 * <p>The coordinates are relative to the center of the arena in a right handed coordinate
	 * system. The view direction ranges from -180&deg; to 180&deg; and is relative to the 
	 * x-axis. A positive view direction means the robot is looking into the positive 
	 * y-direction. The reference point is the center of the robot's rear axle.</p>
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * @return the opponent's current absolute position
	 */
	@Calculated
	override RobotPosition getOpponentPosition() {
	}

	/**
	 * Get the bearing of your opponent. This is given in polar coordinates relative to 
	 * your robot's current position. The distance is in centimeter. The angle is relative 
	 * to your robot's view direction in degrees, and ranges between -180&deg; and 180&deg;.
	 * 
	 * <p>The reference points are the centers of the robots' rear axles.</p>
	 * 
	 * <p>The following picture illustrates the values of the angle <code>a</code> and 
	 * <code>length</code> with respect to the own view direction.
	 * <img src="doc-files/Bearing.jpg"/></p>
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * @return the relative distance and angle to the opponent
	 */
	@Calculated
	override Vector getOpponentBearing() {
	}

	/**
	 * Get the bearing of the center of the arena. This is given in polar coordinates relative
	 * to your robot's current position. The distance is in centimeter. The angle is relative 
	 * to your robot's view direction in degrees, and ranges between -180&deg; and 180&deg;.
	 * 
	 * <p>The reference point is the center of the robot's rear axle.</p>
	 * 
	 * <p>If this command is called repeatedly in the same mode, it returns the same values
	 * unless the robot state is updated with the {@link #update()} command.</p>
	 * 
	 * @return the relative distance and angle to the center of the arena
	 */
	@Calculated
	override Vector getCenterBearing() {
	}
	
}
