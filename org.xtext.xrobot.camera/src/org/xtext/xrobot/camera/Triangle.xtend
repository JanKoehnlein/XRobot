package org.xtext.xrobot.camera

import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.opencv.core.Point
import static org.xtext.xrobot.camera.GeometryUtils.*

@Accessors(PUBLIC_GETTER)
@FinalFieldsConstructor
class Triangle {

	val int robotID
	val Set<Point> corners
	
	Point midpoint
	Point forwardCorner

	def Point getForwardCorner() {
		if(forwardCorner == null) {
			var maxDist = Double.MIN_VALUE
			for (Point p : corners) {
				val dist = distance(getMidpoint(), p)
				if (dist > maxDist) {
					maxDist = dist
					forwardCorner = p
				}
			}
		}
		return forwardCorner
	}

	def Point getMidpoint() {
		if(midpoint == null) {
			midpoint = new Point
			for (Point p : corners) {
				midpoint.x += p.x / 3
				midpoint.y += p.y / 3
			}
		}
		return midpoint
	}
	
	def double getAngle() {
		angle(getForwardCorner().x - midpoint.x, getForwardCorner().y - midpoint.y)
	}
}