package org.xtext.xrobot.game.tests.di

import java.net.SocketTimeoutException
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.server.IRemoteRobot

@Accessors
class MockRobotFactory implements IRemoteRobot.Factory {
	
	RobotID robotID
	
	new(RobotID robotID) {
		this.robotID = robotID
	}
	
	override release() {
	}
	
	override reset() {
	}
	
	override isAlive() {
		true
	}
	
	override newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException {
		new MockRobot(robotID, cancelIndicator)
	}
	
	override newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot) {
		new MockRobot(robotID, cancelIndicator)
	}
	
}