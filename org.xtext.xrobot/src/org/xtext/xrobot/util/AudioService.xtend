/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.util

import com.google.common.collect.HashMultimap
import com.sun.speech.freetts.Voice
import com.sun.speech.freetts.VoiceManager
import com.sun.speech.freetts.en.us.cmu_us_kal.KevinVoiceDirectory
import java.util.Arrays
import javafx.scene.media.AudioClip
import org.apache.log4j.Logger
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.Sample

import static org.xtext.xrobot.util.AudioService.*

class AudioService {

	interface Listener {
		def void audioStarted(String text)
		def void audioStopped()
	}
	
	/** Limit on the number of audio invocations. */
	public static val AUDIO_CALL_LIMIT = 20
	/** Limit on the number of characters in a text string. */
	public static val TEXT_LENGTH_LIMIT = 24

	static val INSTANCE = new AudioService

	static val LOG = Logger.getLogger(AudioService)

	val Voice kevin

	val samples = <Sample, AudioClip>newHashMap

	val listeners = HashMultimap.<RobotID, Listener>create
	
	val threads = <Thread>newArrayOfSize(RobotID.values.length)
	
	val audioCounters = newIntArrayOfSize(RobotID.values.length)

	static def getInstance() {
		INSTANCE
	}

	private new() {
		System.setProperty("freetts.voices", KevinVoiceDirectory.canonicalName)
		val voiceManager = VoiceManager.getInstance
		kevin = voiceManager.getVoice('kevin16')
		kevin.pitch = 30 // low pitch sounds more artificial
		kevin.allocate
	}

	def addAudioListener(RobotID robotID, Listener listener) {
		listeners.put(robotID, listener)
	}

	def removeAudioListener(RobotID robotID, Listener listener) {
		listeners.remove(robotID, listener)
	}
	
	def resetCounters() {
		Arrays.fill(audioCounters, 0)
	}

	def speak(String text, RobotID robotID) {
		if (text.length > TEXT_LENGTH_LIMIT) {
			LOG.info("Blocked audio message due to excessive length.")
		} else {
			playInBackground([
				kevin.speak(text)
			], text, robotID)
		}
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
		synchronized (threads) {
			val index = robotID.ordinal
			val previousThread = threads.get(index)
			if (previousThread == null || !previousThread.alive) {
				audioCounters.set(index, audioCounters.get(index) + 1)
				if (audioCounters.get(index) > AUDIO_CALL_LIMIT) {
					LOG.info("Blocked audio message due to excessive number of calls: " + text)
				} else {
					val playThread = new Thread(robotID + ' Audio Player') {
						override run() {
							listeners.get(robotID).forEach[
								audioStarted(text)
							]
							runnable.run
							listeners.get(robotID).forEach[
								audioStopped
							]
						}
					} => [
						daemon = true
						priority = Thread.MIN_PRIORITY
					]
					playThread.start
					threads.set(index, playThread)
				}
			} else {
				LOG.info('Blocked audio message because audio is already playing: ' + text)
			}
		}
	}
}
