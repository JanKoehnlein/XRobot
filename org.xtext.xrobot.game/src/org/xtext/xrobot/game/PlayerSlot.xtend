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
	
	def placeRobot() {
		// TODO: this does not work at all due to missing calibration
//		val robot = getRobotFactory.newRobot(CancelIndicator.NullImpl)
//		val startPosition = switch robotID {
//			case Xtend: new Position(-IArena.ARENA_RADIUS * 0.7, 0)
//			case Xtext: new Position(IArena.ARENA_RADIUS * 0.7, 0)
//		}
//		var direction = robot.ownPosition.getRelativeDirection(startPosition)
////		do {
//			robot.curveTo(direction.distance / 4, direction.angle)
//			robot.update
////			val ownPosition = robot.ownPosition
////			direction = (ownPosition).getRelativeDirection(startPosition)
////		} while(direction.distance > 4)
//		val startViewDirection = switch robotID {
//			case Xtend: 180
//			case Xtext: 0
//		}
////		do {
//			robot.rotate(startViewDirection)
//			robot.update
////		} while(abs(normalizeAngle(startViewDirection - robot.ownPosition.viewDirection)) > 5)
	}
	
	def matches(AccessToken token) {
		this.token == token
	}

	def isAvailable() {
		program == null
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
