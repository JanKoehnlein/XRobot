package org.xtext.xrobot.game

import com.google.inject.Binder
import com.google.inject.Module
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobotConnector
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.game.ui.GameControlWindow

class XRobotModule implements Module {
	
	override configure(Binder binder) {
		binder.bind(IRemoteRobot.Connector).to(RemoteRobotConnector)
		binder.bind(IScriptPoller).to(ScriptPoller)
		binder.bind(IRobotPreparer).to(RobotPreparer)
		binder.bind(IErrorReporter).to(Display)
		binder.bind(IGameListener).to(GameControlWindow)
	}
	
}