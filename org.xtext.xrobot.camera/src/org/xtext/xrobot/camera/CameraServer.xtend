package org.xtext.xrobot.camera

import com.illposed.osc.OSCBundle
import com.illposed.osc.OSCMessage
import com.illposed.osc.OSCPortOut
import java.net.InetAddress
import org.xtext.xrobot.net.CameraView

class CameraServer {
	
	def static void main(String[] args) {
		new CameraServer().run
	}
	
	OSCPortOut port = new OSCPortOut(InetAddress.localHost, 3333)
	
	int frameID
	
	def void run() {
		new TriangleScanner().run(this)	
	}
	
	def void sendPositions(Triangle[] triangles, TriangleScanParameters[] params) {
		val bundle = new OSCBundle
		bundle.addPacket(new OSCMessage('/tuio/2Dobj', #[
			'source',
			'camera@localhost'
		]))
		bundle.addPacket(new OSCMessage('/tuio/2Dobj') => [
			addArgument('alive')
			for(p: params)
				addArgument(p.sessionID) 
		]);
		for(t: triangles.filterNull) 
			bundle.addPacket(new OSCMessage('/tuio/2Dobj', #[
				'set',
				params.get(t.robotID).sessionID,
				t.robotID,
				t.midpoint.x as float / CameraView.RESOLUTION_X,
				t.midpoint.y as float / CameraView.RESOLUTION_Y,
				t.angle as float,
				0f, // we don't measure speed, acceleration etc.
				0f,
				0f,
				0f,
				0f
			]))
		bundle.addPacket(new OSCMessage('/tuio/2Dobj', #[
			'fseq',
			frameID++
		]))
		port.send(bundle)
	}
}