package org.xtext.xrobot.camera

import org.eclipse.xtend.lib.annotations.Accessors
import org.opencv.core.Scalar
import java.util.Random

@Accessors(PUBLIC_GETTER)
class TriangleScanParameters {

	val String name

	val int id;

	val int sessionID = new Random().nextInt

	volatile Scalar minTriangleColor

	volatile Scalar maxTriangleColor

	@Accessors(PUBLIC_SETTER, PACKAGE_GETTER)
	volatile int minContourPoints;

	new(String name, int id, Scalar minTriangleColor, Scalar maxTriangleColor, int minContourPoints) {
		this.name = name
		this.id = id
		this.minTriangleColor = minTriangleColor
		this.maxTriangleColor = maxTriangleColor
		this.minContourPoints = minContourPoints
	}
}
