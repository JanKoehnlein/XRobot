package org.xtext.xrobot.camera

interface ICamera {
	
	val RESOLUTION_X = 1920
	val RESOLUTION_Y = 1080
	val ASPECT_RATIO = RESOLUTION_X as double / RESOLUTION_Y
	
	val WIDTH_IN_CM = 200.0
	val HEIGHT_IN_CM = 200.0 / ASPECT_RATIO
}