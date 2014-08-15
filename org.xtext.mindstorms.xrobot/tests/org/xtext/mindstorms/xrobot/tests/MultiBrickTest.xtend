package org.xtext.mindstorms.xrobot.tests

import lejos.hardware.BrickFinder
import lejos.remote.ev3.RemoteEV3

class MultiBrickTest {
	def static void main(String[] args) {
		val bricks = BrickFinder.discover();
		for (info : bricks) {
			val brick = new RemoteEV3(info.getIPAddress());
			println(info.name + " " + info.IPAddress + " (" + info.type + ")")
			brick.getAudio().systemSound(0);
		}
	}
}
