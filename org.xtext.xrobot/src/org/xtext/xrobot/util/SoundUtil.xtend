package org.xtext.xrobot.util

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
		if (sample == null) {
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
			while (true) {
				var read = in.read(buffer);
				if (read < 0) 
					return out.toByteArray
				out.write(buffer, 0, read)
			}
		} finally {
			in?.close
			out?.close
		}
	}

}
