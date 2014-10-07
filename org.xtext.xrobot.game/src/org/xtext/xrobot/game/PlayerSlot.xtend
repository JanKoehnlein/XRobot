package org.xtext.xrobot.game

import java.util.concurrent.CopyOnWriteArrayList
import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.game.display.Display
import org.xtext.xrobot.server.IRemoteRobot

import static org.xtext.xrobot.game.PlayerStatus.*
import com.google.inject.Provider

@Accessors(PUBLIC_GETTER)
class PlayerSlot implements IRobotListener {

	RobotID robotID

	IRemoteRobot.Connector connector
	
	Display display

	Program program

	AccessToken token

	IRemoteRobot.Factory robotFactory

	@Accessors(NONE)
	RobotPreparer preparer
	
	PlayerStatus status = AVAILABLE

	val listeners = new CopyOnWriteArrayList<Listener>

	new(RobotID robotID, IRemoteRobot.Connector connector, Display display,
			Provider<? extends RobotPreparer> preparerProvider) {
		this.robotID = robotID
		this.connector = connector
		this.display = display
		token = new AccessToken
		preparer = preparerProvider.get()
		preparer.slot = this
	}
	
	def getRobotFactory() {
		if(robotFactory == null || !robotFactory.isAlive)
			robotFactory = connector.getRobotFactory(robotID)
		robotFactory
	}
	
	def setStatus(PlayerStatus status) {
		this.status = status
		listeners.forEach[slotChanged]
	}
	
	def matches(AccessToken token) {
		this.token == token
	}

	def isAvailable() {
		program == null
	}

	def acquire(Program program) {
		this.program = program
		preparer.getReady
	}
	
	def waitReady() {
		preparer.waitReady
		if(status != READY) {
			display?.addKeyAction[preparer.getReady]
		}
		return status == READY
	}

	def release() {
		this.program = null
		robotFactory?.release
		token = new AccessToken
		status = AVAILABLE
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
