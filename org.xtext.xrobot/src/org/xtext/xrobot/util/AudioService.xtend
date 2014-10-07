package org.xtext.xrobot.util

import com.google.common.collect.HashMultimap
import com.sun.speech.freetts.Voice
import com.sun.speech.freetts.VoiceManager
import javafx.scene.media.AudioClip
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.Sample

class AudioService {

	interface Listener {
		def void audioStarted(String text)
		def void audioStopped()
	}

	static var INSTANCE = new AudioService

	val Voice kevin

	val samples = <Sample, AudioClip>newHashMap

	val listeners = HashMultimap.<RobotID, Listener>create 

	static def getInstance() {
		INSTANCE
	}

	private new() {
		val voiceManager = VoiceManager.getInstance
		kevin = voiceManager.getVoice('kevin16');
		kevin.pitch = 30 // low pitch sounds more artificial
		kevin.allocate
	}

	def addAudioListener(RobotID robotID, Listener listener) {
		listeners.put(robotID, listener)
	}

	def removeAudioListener(RobotID robotID, Listener listener) {
		listeners.remove(robotID, listener)
	}

	def speak(String text, RobotID robotID) {
		playInBackground([
			kevin.speak(text)
		], text, robotID)
	}

	def play(Sample sample, RobotID robotID) {
		var clip = samples.get(sample)
		if (clip == null) {
			val path = '/samples/' + sample.name.toLowerCase + '.wav'
			clip = new AudioClip(AudioService.getResource(path).toString)
			samples.put(sample, clip)
		}
		val finalClip = clip
		playInBackground([
			val pan = getPan(robotID)
			finalClip.play(1.0, pan, 1.0, pan, 0)
			while(finalClip.playing) 
				Thread.sleep(100)
		], sample.text, robotID)
	}

	private def getPan(RobotID robotID) {
		robotID.fiducialID * 2 - 1
	}

	private def playInBackground(Runnable runnable, String text, RobotID robotID) {
		new Thread(
			[
				listeners.get(robotID).forEach[
					audioStarted(text)
				]
				runnable.run
				listeners.get(robotID).forEach[
					audioStopped
				]
			], 'AudioPlayer') => [
				daemon = true
				priority = Thread.MIN_PRIORITY
				start
			]
	}
}
