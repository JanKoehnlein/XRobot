package org.xtext.xrobot.camera

import org.opencv.core.Point
import static extension java.lang.Math.*

class GeometryUtils {
	static def distance(Point a, Point b) {
		return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
	}

	static def angle(double dx, double dy) {
		atan2(-dy, dx)
	}
}
