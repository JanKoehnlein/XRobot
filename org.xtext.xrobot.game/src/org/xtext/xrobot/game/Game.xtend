package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.ArrayList
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.api.IArena
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.ScriptRunner
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.IRemoteRobot

class Game {
	
	static val LOG = Logger.getLogger(Game)
	
	static val GAME_DURATION = 1000l * 60 * 2 // 2 minutes in millis
	static val GAME_LOST_THRESHOLD = 500 
	 
	@Inject Provider<ScriptRunner> scriptRunnerProvider
	
	List<Thread> runners

	Throwable gameException
	volatile boolean gameOver
	
	long lastLoserTimeStamp = -1
	RobotID loser

	def play(List<PlayerSlot> slots) {
		val gameOverListener = createGameOverListener
		// remember map is lazy, so make a real copy
		runners = new ArrayList(slots.map[ prepareScriptRunner(program, robotFactory, gameOverListener)])
		gameOver = false
		runners.forEach[start]
		runners.forEach[executeSafely[join(GAME_DURATION)]]
		gameOver = true
		slots.forEach[
			executeSafely[ robotFactory.release ]
		]
	}
	
	def getLoser() {
		if(gameException == null) 
			loser
		else 
			null
	}
	
	def getException() { gameException }
	
	def createGameOverListener() {
		new IRobotListener() {
			override modeChanged(IRemoteRobot robot, Mode newMode) {
			}
			
			override stateChanged(IRemoteRobot robot) {
			}
			
			override variableChanged(String name, Object value) {
			}
			
			override lineChanged(int line) {
			}
			
			override stateRead(IRemoteRobot robot) {
				checkGameOver(robot)
			}
		}
	}

	private def checkGameOver(IRemoteRobot robot) {
		if(robot.centerDirection.distance > IArena.ARENA_RADIUS) {
			if(loser == null)  
				loser = robot.robotID
			else if(System.currentTimeMillis - lastLoserTimeStamp < GAME_LOST_THRESHOLD) {
				// robots were losing almost simultaneously: a draw
				loser = null
			}
			gameOver = true
		}
	}

	private def prepareScriptRunner(Program program, IRemoteRobot.Factory robotFactory, IRobotListener... listeners) {
		val scriptExecutor = scriptRunnerProvider.get
		listeners.forEach[scriptExecutor.addRobotListener(it)]
		new Thread [
			executeSafely [
				if (!robotFactory.isAlive)
					throw new RuntimeException('Robot ' + robotFactory.robotID + ' not ready')
				scriptExecutor.run(
					program,
					robotFactory,
					new CancelIndicator() {
						override isCanceled() {
							gameOver
						}
					})
			]
		]
	}

	private def executeSafely(Runnable runnable) {
		try {
			runnable.run()
		} catch(Exception e) {
			LOG.error(e.message, e)
			gameException = e
			gameOver = true
		}
	}
}

