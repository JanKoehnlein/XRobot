package org.xtext.xrobot.util

import java.util.Map
import javafx.scene.media.AudioClip
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.Sample

class SoundUtil {

	static Map<Sample, AudioClip> samples = newHashMap

	static def play(Sample sample, RobotID robotID) {
		var clip = samples.get(sample)
		if(clip == null) {
			val path = '/samples/' + sample.name.toLowerCase + '.wav'
			clip = new AudioClip(SoundUtil.getResource(path).toString)
			samples.put(sample, clip)
		}
		clip.playInBackground(robotID.fiducialID * 2 - 1)
	}
	
	private static def playInBackground(AudioClip clip, double pan) {
		new Thread [
			clip.play(1.0, pan, 1.0, pan, 0)
		].start
	}


}
