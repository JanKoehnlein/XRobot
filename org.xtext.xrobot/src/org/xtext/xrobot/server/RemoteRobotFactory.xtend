/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.server

import java.net.SocketTimeoutException
import java.nio.channels.SocketChannel
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.Wrapper
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraClient
import org.xtext.xrobot.camera.CameraTimeoutException

import static org.xtext.xrobot.net.INetConfig.*
import static org.xtext.xrobot.util.IgnoreExceptionsExtension.*

class RemoteRobotFactory implements IRemoteRobot.Factory {
	
	val RobotID robotID 
	
	val SocketChannel socket
	
	val writeLock = new Object
	
	val StateReceiver stateReceiver
	
	val CameraClient cameraClient
	
	var boolean isReleased
	
	val nextCommandSerialNr = new Wrapper<Integer>
	
	@Accessors(PUBLIC_GETTER)
	var RemoteRobot lastRobot
	
	new(RobotID robotID, SocketChannel socket, CameraClient cameraClient) throws SocketTimeoutException, CameraTimeoutException {
		try {
			this.robotID = robotID
			this.socket = socket
			stateReceiver = new StateReceiver(socket)
			stateReceiver.start
			this.cameraClient = cameraClient
			nextCommandSerialNr.set(10)
		} catch(Exception exc) {
			ignoreExceptions[stateReceiver?.shutdown]
			throw exc
		}
	}
	
	override getRobotID() {
		robotID
	}
	
	override void release() {
		if(!isReleased) {
			ignoreExceptions[lastRobot?.release]
			stateReceiver.shutdown
			ignoreExceptions[socket?.close]
			isReleased = true
		}
	}
	
	override void reset() {
		lastRobot?.reset
	}
	
	override isAlive() {
		!isReleased && stateReceiver.isAlive
	}
	
	override newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException {
		if (!alive) {
			throw new IllegalStateException
		}
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, writeLock, stateReceiver,
				cancelIndicator, cameraClient)
		lastRobot.waitForUpdate(10 * SOCKET_TIMEOUT)
		lastRobot
	}
	
	override newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot) {
		if (!alive) {
			throw new IllegalStateException
		}
		lastRobot = new RemoteRobot(robotID, nextCommandSerialNr, socket, writeLock, stateReceiver,
				cancelIndicator, cameraClient)
		val existingRemoteRobot = existingRobot as RemoteRobot
		lastRobot.setState(existingRemoteRobot.state, existingRemoteRobot.cameraSample)
		lastRobot
	}
	
}
