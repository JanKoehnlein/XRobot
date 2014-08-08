package org.xtext.mindstorms.xrobot.util

import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.util.Map
import lejos.hardware.Audio

class SoundUtil {
	
	Map<String, byte[]> samples = newHashMap
	
	def playSample(Audio audio, String fileName, int volume) {
		val sample = fileName.sample
		audio.playSample(sample, 0, sample.length, 8000, volume)
	}
	
	protected def getSample(String fileName) {
		var sample = samples.get(fileName)
		if(sample == null) {
			sample = loadSample(fileName) 
			samples.put(fileName, sample)			
		} 
		sample
	}
	
	protected def loadSample(String fileName) {
		var InputStream in = null
		var ByteArrayOutputStream out = null
		try {
			in = class.classLoader.getResourceAsStream(fileName)
			out = new ByteArrayOutputStream
			var byte[] buffer = newByteArrayOfSize(2048)
			var int size  
			while((size = in.read(buffer)) > 0) {
				out.write(buffer, 0, size)
			}
			out.flush
			return  out.toByteArray
		} finally {
			in?.close
			out?.close
		}
	}
	
}