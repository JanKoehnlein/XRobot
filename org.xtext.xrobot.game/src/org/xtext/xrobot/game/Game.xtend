package org.xtext.xrobot.game

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.ArrayList
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.api.IArena
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.ScriptRunner
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.IRemoteRobot

import static org.xtext.xrobot.game.GameResult.*

class Game {
	
	static val LOG = Logger.getLogger(Game)
	
	static val GAME_LOST_THRESHOLD = 500 
	 
	@Inject Provider<ScriptRunner> scriptRunnerProvider
	
	@Accessors
	long gameDuration
	
	List<Thread> runners

	volatile boolean gameOver
	
	long lastLoserTimeStamp = -1
	
	@Accessors(PUBLIC_GETTER)
	GameResult gameResult
	
	@Accessors(PUBLIC_GETTER)
	GameResult refereeResult
	
	def play(List<PlayerSlot> slots) {
		val gameOverListener = createGameOverListener
		// remember map is lazy, so make a real copy
		runners = new ArrayList(slots.map[ prepareScriptRunner(program, robotFactory, gameOverListener, it)])
		gameOver = false
		LOG.debug('Starting game')
		runners.forEach[start]
		runners.forEach[executeSafely[join(gameDuration)]]
		LOG.debug('Game finished')
		gameOver = true
		slots.forEach[
			executeSafely[ robotFactory.release ]
		]
		if(gameResult == null)
			gameResult = draw
	}
	
	def setRefereeResult(GameResult refereeResult) {
		this.refereeResult = refereeResult
		gameOver = true
	}
	
	private def createGameOverListener() {
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
		if(robot.centerDirection.distance > IArena.ARENA_OUTER_RADIUS || robot.isDead) {
			if(gameResult == null) {
				gameResult = defeat(robot.robotID)
				lastLoserTimeStamp = System.currentTimeMillis
			} else if(refereeResult == null && System.currentTimeMillis - lastLoserTimeStamp < GAME_LOST_THRESHOLD) {
				// robots were losing almost simultaneously: a draw
				gameResult = draw
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
			gameResult = canceled(e.message)
			gameOver = true
		}
	}
}

