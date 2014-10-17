package org.xtext.xrobot.game.tests

import org.junit.Test
import org.xtext.xrobot.api.RobotPosition
import org.xtext.xrobot.api.Vector
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.camera.CameraConstants
import org.xtext.xrobot.util.AveragingFilter
import org.xtext.xrobot.util.MultiplyingFilter

import static org.junit.Assert.*

import static extension java.lang.Math.*
import static extension org.xtext.xrobot.api.GeometryExtensions.*

class GeometryTest {
	
	static val ACCURACY = 1e-5
	
	@Test
	def testMinimizeAngle() {
		assertEquals(90.0, minimizeAngle(450), ACCURACY)
		assertEquals(90.0, minimizeAngle(-270), ACCURACY)
		assertEquals(-90.0, minimizeAngle(-450), ACCURACY)
		assertEquals(-90.0, minimizeAngle(270), ACCURACY)
	}
	
	@Test
	def testVectorConversion() {
		assertEquals(45.0, Vector.cartesian(10, 10).angle, ACCURACY)
		assertEquals(5.0, Vector.cartesian(4, 3).length, ACCURACY)
		assertEquals(-10.0, Vector.polar(10, 180).x, ACCURACY)
		assertEquals(-5.0, Vector.polar(sqrt(50), -45).y, ACCURACY)
	}
	
	@Test
	def testVectorOperators() {
		assertEquals(10.0, (Vector.cartesian(10, 10) + Vector.polar(10, -90)).length, ACCURACY)
		assertEquals(0.0, (Vector.cartesian(0, 5) - Vector.polar(sqrt(50), 135)).angle, ACCURACY)
		assertEquals(-135.0, (-Vector.polar(10, 45)).angle, ACCURACY)
		assertEquals(20.0, (Vector.polar(10, 30) * 2).length, ACCURACY)
		assertEquals(20.0, (2 * Vector.polar(10, -30)).length, ACCURACY)
		assertEquals(10.0, (Vector.polar(20, 60) / 2).length, ACCURACY)
		assertEquals(180.0, Vector.cartesian(0, 10).rotate(90).angle, ACCURACY)
	}
	
	@Test
	def testAveragingFilter() {
		val filter = new AveragingFilter(3, 10.0)
		assertEquals(1.0, filter.apply(1), ACCURACY)
		assertEquals(1.5, filter.apply(2), ACCURACY)
		assertEquals(2.0, filter.apply(3), ACCURACY)
		assertEquals(3.0, filter.apply(4), ACCURACY)
		assertEquals(-6.0, filter.apply(-5), ACCURACY)
	}
	
	@Test
	def testMultiplyingFilter() {
		val filter = new MultiplyingFilter(0.5, 10.0)
		assertEquals(0.5, filter.apply(1), ACCURACY)
		assertEquals(1.25, filter.apply(2), ACCURACY)
		assertEquals(2.125, filter.apply(3), ACCURACY)
		assertEquals(3.0625, filter.apply(4), ACCURACY)
		assertEquals(-5.96875, filter.apply(-5), ACCURACY)
	}
	
	@Test
	def testPositionPerspective() {
		val p = CameraConstants.PERSPECTIVE_CORRECTION
		assertEquals(p * 10.0,
				CameraClient.correctPositionPerspective(Vector.cartesian(10, 0)).length,
				ACCURACY)
		assertEquals(p * 10.0,
				CameraClient.correctPositionPerspective(Vector.polar(10, -30)).length,
				ACCURACY)
	}
	
	@Test
	def testSpeedPerspective() {
		val P = CameraConstants.PERSPECTIVE_CORRECTION
		var a = 45.0
		for (i : 1..4) {
			val s1 = CameraClient.correctSpeedPerspective(Vector.polar(5, a), Vector.polar(10, a))
			assertEquals(P * 5.0, s1.length, ACCURACY)
			assertEquals(minimizeAngle(a), s1.angle, ACCURACY)
			val s2 = CameraClient.correctSpeedPerspective(Vector.polar(5, a + 180), Vector.polar(10, a))
			assertEquals(P * 5.0, s2.length, ACCURACY)
			assertEquals(minimizeAngle(a + 180), s2.angle, ACCURACY)
			val s3 = CameraClient.correctSpeedPerspective(Vector.polar(5, a + 90), Vector.polar(10, a))
			assertEquals(5.0, s3.length, ACCURACY)
			assertEquals(minimizeAngle(a + 90.0), s3.angle, ACCURACY)
			val s4 = CameraClient.correctSpeedPerspective(Vector.cartesian(4, 3).rotate(a), Vector.polar(10, a))
			assertEquals(sqrt(P * P * 16 + 9), s4.length, ACCURACY)
			assertEquals(minimizeAngle(a + atan(3 / (P * 4)).toDegrees), s4.angle, ACCURACY)
			a += 90
		}
	}
	
	@Test
	def testRobotPosition() {
		val rp = new RobotPosition(10, 10, Vector.cartesian(-5, 0), 180, 0)
		assertEquals(90.0, rp.getRelativePosition(Vector.cartesian(10, 5)).angle, ACCURACY)
		assertEquals(5.0, rp.getRelativePosition(Vector.cartesian(10, 15)).length, ACCURACY)
		assertEquals(-30.0, rp.getRelativeSpeed(Vector.polar(5, 150)).angle, ACCURACY)
	}
	
}