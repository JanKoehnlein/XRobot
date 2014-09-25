package org.xtext.xrobot.game

import java.util.concurrent.CopyOnWriteArrayList
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.IRemoteRobot

@Accessors(PUBLIC_GETTER)
class PlayerSlot implements IRobotListener {

	RobotID robotID

	Program program

	AccessToken token

	IRemoteRobot.Connector connector

	IRemoteRobot.Factory robotFactory

	val listeners = new CopyOnWriteArrayList<Listener>

	new(RobotID robotID, IRemoteRobot.Connector connector) {
		this.robotID = robotID
		this.connector = connector
		token = new AccessToken
	}
	
	def getRobotFactory() {
		if(robotFactory == null || !robotFactory.isAlive)
			robotFactory = connector.getRobotFactory(robotID)
		robotFactory
	}

	def matches(AccessToken token) {
		this.token == token
	}

	def isAvailable() {
		program != null
	}

	def acquire(Program program) {
		this.program = program
		listeners.forEach[slotChanged]
	}

	def release() {
		this.program = null
		token = new AccessToken
		listeners.forEach[slotChanged]
	}

	def addChangeListener(Listener listener) {
		listeners += listener
	}

	def getScriptName() {
		program.name
	}

	static interface Listener extends IRobotListener {
		def void slotChanged()
	}

	override stateRead(IRemoteRobot robot) {
		listeners.forEach[stateRead(robot)]
	}

	override modeChanged(IRemoteRobot robot, Mode newMode) {
		listeners.forEach[modeChanged(robot, newMode)]
	}

	override stateChanged(IRemoteRobot robot) {
		listeners.forEach[stateChanged(robot)]
	}

	override variableChanged(String name, Object value) {
		listeners.forEach[variableChanged(name, value)]
	}

	override lineChanged(int line) {
		listeners.forEach[lineChanged(line)]
	}

}
