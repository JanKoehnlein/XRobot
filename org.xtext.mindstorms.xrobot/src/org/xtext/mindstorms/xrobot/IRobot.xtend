package org.xtext.mindstorms.xrobot

import org.xtext.mindstorms.xrobot.geometry.Polar

interface IRobot {

	def void forward(double distance)

	def void backward(double distance)

	def void setTravelSpeed(double speed)

	def double getTravelSpeed()

	def double getMaxTravelSpeed()

	def void rotate(double angle)

	def void setRotateSpeed(double speed)

	def double getRotateSpeed()

	def double getRotateMaxSpeed()

	def void curveForward(double radius, double angle)

	def void curveBackward(double radius, double angle)
	
	def void curveTo(Polar bearing)
	
	def void stop()

	def float measureDistance()

	def Polar measureEnemyBearing()

	def float measureGroundColor()

	def float measureShieldContact()

	def boolean escapePressed()
	
	def void fireWeapon()
}
