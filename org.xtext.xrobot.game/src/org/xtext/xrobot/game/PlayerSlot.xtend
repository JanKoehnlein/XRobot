package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import java.net.SocketTimeoutException
import java.util.ArrayList
import java.util.concurrent.CopyOnWriteArrayList
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.resource.XtextResourceSet
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraTimeoutException
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.ScriptParser
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.IRemoteRobot

import static org.xtext.xrobot.game.PlayerStatus.*

class PlayerSlot implements IRobotListener {
	
	static val MAX_PARSE_TIME = 10000
	static val MAX_LABEL_LENGTH = 20
	
	static val LOG = Logger.getLogger(PlayerSlot)
	
	static class Factory {
	
		@Inject IRemoteRobot.Connector remoteRobotConnector
		
		@Inject IErrorReporter display
		
		@Inject Provider<IRobotPreparer> robotPreparerProvider
		
		@Inject Provider<XtextResourceSet> resourceSetProvider
		
		@Inject ScriptParser scriptParser
		
		def create(RobotID robotID) {
			new PlayerSlot(robotID, remoteRobotConnector, display, robotPreparerProvider,
					resourceSetProvider, scriptParser)
		}
		
		def createAll() {
			new ArrayList(RobotID.values.map[create])
		}
		
	}

	@Accessors(PUBLIC_GETTER)
	val RobotID robotID

	@Accessors(PUBLIC_GETTER)
	val IErrorReporter display

	val IRemoteRobot.Connector connector
	
	val Provider<XtextResourceSet> resourceSetProvider
	
	@Accessors(PUBLIC_GETTER)
	val ScriptParser scriptParser
	
	@Accessors(PUBLIC_GETTER)
	Program program

	@Accessors(PUBLIC_GETTER)
	AccessToken token

	@Accessors(PUBLIC_GETTER)
	PlayerStatus status = AVAILABLE

	IRemoteRobot.Factory robotFactory

	val listeners = new CopyOnWriteArrayList<Listener>
	val robotListeners = new CopyOnWriteArrayList<IRobotListener>

	val IRobotPreparer preparer
	
	private new(RobotID robotID, IRemoteRobot.Connector connector, IErrorReporter display,
			Provider<? extends IRobotPreparer> preparerProvider,
			Provider<XtextResourceSet> resourceSetProvider,
			ScriptParser scriptParser) {
		this.robotID = robotID
		this.connector = connector
		this.display = display
		this.resourceSetProvider = resourceSetProvider
		this.scriptParser = scriptParser
		token = new AccessToken
		preparer = preparerProvider.get()
		preparer.slot = this
	}
	
	override toString() {
		if (program == null) {
			class.simpleName + ' ' + robotID
		} else {
			class.simpleName + ' ' + robotID + '[' + program.name + ']'
		}
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
		if (program.name.nullOrEmpty) {
			throw new IllegalArgumentException("Program has no name")
		}
		if (program.author.nullOrEmpty) {
			throw new IllegalArgumentException("Author has no name")
		}
		if (program.name.length > MAX_LABEL_LENGTH) {
			program.name = program.name.substring(0, MAX_LABEL_LENGTH) + "..."
		}
		if (program.author.length > MAX_LABEL_LENGTH) {
			program.author = program.author.substring(0, MAX_LABEL_LENGTH) + "..."
		}
		this.program = program
		prepare
	}
	
	def acquire(String uri, String serializedProgram) {
		val startTime = System.currentTimeMillis
		val program = scriptParser.parse(uri, serializedProgram, resourceSetProvider.get,
				[System.currentTimeMillis - startTime > MAX_PARSE_TIME])
		if (program != null) {
			acquire(program)
		}
	}
	
	def prepare() {
		try {
			preparer.prepare
		} catch (CameraTimeoutException cte) {
			LOG.info(cte.message)
			setStatus(NO_CAMERA)
		} catch (SocketTimeoutException ste) {
			LOG.warn(ste.message)
			setStatus(NO_CONNECTION)
		}
	}
	
	def waitReady() {
		preparer.waitReady
		return status == READY
	}	
	
	def release() {
		this.program = null
		preparer.cancel
		robotFactory?.release
		token = new AccessToken
		status = AVAILABLE
		listeners.forEach[slotChanged]
	}

	def addSlotListener(Listener listener) {
		listeners += listener
	}

	def addRobotListener(IRobotListener listener) {
		robotListeners += listener
	}

	def getScriptName() {
		program?.name
	}

	static interface Listener {
		def void slotChanged()
	}

	override stateRead(IRemoteRobot robot) {
		robotListeners.forEach[stateRead(robot)]
	}

	override modeChanged(IRemoteRobot robot, Mode newMode) {
		robotListeners.forEach[modeChanged(robot, newMode)]
	}

	override stateChanged(IRemoteRobot robot) {
		robotListeners.forEach[stateChanged(robot)]
	}

	override variableChanged(String name, Object value) {
		robotListeners.forEach[variableChanged(name, value)]
	}

	override lineChanged(int line) {
		robotListeners.forEach[lineChanged(line)]
	}

}
