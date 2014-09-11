package org.xtext.xrobot.camera

import TUIO.TuioClient
import TUIO.TuioListener
import TUIO.TuioCursor
import TUIO.TuioObject
import TUIO.TuioTime

class CameraClient {
	
	def static void main(String[] args) {
		new CameraClient
	}
	
	new() {
		val tuioClient = new TuioClient()
		tuioClient.connect
		tuioClient.addTuioListener(new TuioListener() {
			
			override addTuioCursor(TuioCursor tcur) {
				println('Cursor ' + tcur.cursorID + ' added')
			}
			
			override addTuioObject(TuioObject tobj) {
				println('Object ' + tobj.symbolID + ' added')
			}
			
			override refresh(TuioTime ftime) {
				println('Time refreshed')
			}
			
			override removeTuioCursor(TuioCursor tcur) {
				println('Cursor ' + tcur.cursorID + ' removed')
			}
			
			override removeTuioObject(TuioObject tobj) {
				println('Object ' + tobj.symbolID + ' removed')
			}
			
			override updateTuioCursor(TuioCursor tcur) {
				println('Cursor ' + tcur.cursorID + ' updated')
			}
			
			override updateTuioObject(TuioObject tobj) {
				println('Object ' + tobj.symbolID + ' updated')
			}
			
		})
		while(System.in.available <=0) {}
	}
}