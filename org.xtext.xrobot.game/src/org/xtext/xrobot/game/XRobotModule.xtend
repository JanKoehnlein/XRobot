package org.xtext.xrobot.game

import com.google.inject.Binder
import com.google.inject.Module
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobotConnector

class XRobotModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IRemoteRobot.Connector).to(RemoteRobotConnector)
		binder.bind(IScriptPoller).to(ScriptPoller)
		binder.bind(IRobotPreparer).to(RobotPreparer)
	}
	
}