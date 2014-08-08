package org.xtext.mindstorms.xrobot

import org.xtext.mindstorms.xrobot.geometry.Point
import org.xtext.mindstorms.xrobot.geometry.Polar

interface IRobot {
	
	def Point getPosition()
	
	def double getBearing()
	
	/**
	 * @param angle in degrees
	 */
	def void rotate(double angle)
	
	/**
	 * @param distance in cm
	 */
	def void forward(double distance)

	/**
	 * @param distance in cm
	 */
	def void backward(double distance)
	
	def double measureDistance()
	
	def Polar measureEnemyBearing()
	
	def double measureGroundColor()
}