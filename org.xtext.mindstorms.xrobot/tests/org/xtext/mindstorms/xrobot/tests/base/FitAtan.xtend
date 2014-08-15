package org.xtext.mindstorms.xrobot.tests.base

import static java.lang.Math.*

class FitAtan {
	val double[] xValues = #[
		-23, -14, -8, -7, -4, -3, 2, 4, 6, 10, 25   
	]
	
	val double[] yValues = #[
		-44, -42, -32, -26, -21, -10, 10, 17, 18, 24, 34.0
	]
	
	def static void main(String[] args) {
		new FitAtan().run	
	}
	
	def run() {
		var left = 0.0
		var right = 0.5
		var distLeft = dist(left)
		var distRight = dist(left)
		while(right-left > 1E-6) {
			val middle = 0.5*(left+right)
			var distMiddle = dist(middle)
			if(distLeft > distRight) {
				left = middle
				distLeft = distMiddle
			} else {
				right = middle
				distRight = distMiddle
			}
			println(left + " " + distLeft + "    " + right + " " + distRight)
		}
			
	}
	
	def dist(double scale) {
		var sum = 0.0
		for(var i=0; i < xValues.length; i++) 
			sum += abs(atan(xValues.get(i)*scale) * 90.0 / PI - yValues.get(i))
		return sum
	}
}