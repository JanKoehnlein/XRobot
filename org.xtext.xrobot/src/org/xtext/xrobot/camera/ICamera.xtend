package org.xtext.xrobot.camera

import org.xtext.xrobot.api.IArena
import org.xtext.xrobot.api.IRobotGeometry

import static java.lang.Math.*

interface ICamera {

	/** The horizontal resolution of the tracked camera image. */	
	val RESOLUTION_X = 1080
	/** The vertical resolution of the tracked camera image. */
	val RESOLUTION_Y = 1080
	/** The aspect ratio of the tracked camera image. */
	val ASPECT_RATIO = RESOLUTION_X as double / RESOLUTION_Y
	
	/**
	 * The number of pixels corresponding to the radius of the arena.
	 * Note: this value is also configured in the camera tracking application,
	 * where a circle is drawn in order to calibrate the position of the camera.
	 */
	val ARENA_RADIUS_IN_PX = 450

	/** The width in centimeters of the tracked camera image. */	
	val WIDTH_IN_CM = RESOLUTION_X * IArena.ARENA_OUTER_RADIUS / ARENA_RADIUS_IN_PX
	/** The height in centimeters of the tracked camera image. */	
	val HEIGHT_IN_CM = WIDTH_IN_CM / ASPECT_RATIO
	
	/** The angle in degrees of the field of view of the camera with respect to the tracked area. */
	val VIEW_ANGLE = 42.3
	/** The height of the camera from the ground. */
	val CAM_HEIGHT = HEIGHT_IN_CM / (2 * tan(toRadians(VIEW_ANGLE / 2)))
	
	/** A factor to be multiplied with values measured by the tracker (in polar coordinates). */
	val PERSPECTIVE_CORRECTION = (CAM_HEIGHT - IRobotGeometry.HEIGHT) / CAM_HEIGHT
	
}