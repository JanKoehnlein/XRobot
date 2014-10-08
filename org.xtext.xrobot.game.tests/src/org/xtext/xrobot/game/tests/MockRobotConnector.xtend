package org.xtext.xrobot.game.tests

import org.xtext.xrobot.RobotID
import org.xtext.xrobot.server.IRemoteRobot

class MockRobotConnector implements IRemoteRobot.Connector {
	
	override getRobotFactory(RobotID robotID) {
		new MockRobotFactory(robotID)
	}
	
}