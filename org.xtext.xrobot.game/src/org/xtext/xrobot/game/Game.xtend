package org.xtext.xrobot.game

import com.google.common.base.Throwables
import com.google.inject.Inject
import com.google.inject.Provider
import java.net.SocketTimeoutException
import java.util.ArrayList
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.camera.CameraTimeoutException
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.MemoryException
import org.xtext.xrobot.dsl.interpreter.ScriptRunner
import org.xtext.xrobot.dsl.interpreter.XRobotInterpreter.RobotThread
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.IRemoteRobot

import static java.lang.Math.*
import static org.xtext.xrobot.api.IRobot.*
import static org.xtext.xrobot.game.Game.*
import static org.xtext.xrobot.game.GameResult.*
import static org.xtext.xrobot.net.INetConfig.*
import java.net.SocketException

class Game {

	public static val DEFAULT_GAME_DURATION = 1000l * 45   // 45 seconds
	
	static val LOG = Logger.getLogger(Game)
	
	static val GAME_LOST_THRESHOLD = 800
	 
	@Inject Provider<ScriptRunner> scriptRunnerProvider
	
	@Inject ITimeListener timeListener

	@Accessors
	long gameDuration = DEFAULT_GAME_DURATION
	
	List<Thread> runners

	volatile boolean gameOver
	
	long lastLoserTimeStamp
	
	@Accessors(PUBLIC_GETTER)
	Throwable lastError
	
	@Accessors(PUBLIC_GETTER)
	GameResult gameResult
	
	@Accessors(PUBLIC_GETTER)
	GameResult refereeResult
	
	def play(List<PlayerSlot> slots) {
		if (gameDuration <= 0) {
			throw new IllegalStateException("Game duration is not configured.")
		}
		try {
			// Remember map is lazy, so make a real copy
			runners = new ArrayList(slots.map[prepareScriptRunner(program, robotFactory, gameOverListener, it)])
			gameOver = false
			
			if (LOG.infoEnabled)
				LOG.info('Starting game: ' + slots.map[program.name + ' on ' + robotID].join(', '))
			
			runners.forEach[start]
			timer => [
				start
				join
			]
			runners.forEach[join(100)]
		} finally {
			try {
				slots.forEach[robotFactory.checkAndRelease]
			} catch (Throwable t) {
				LOG.info('Error during game cleanup', t)
			}
			if (gameResult == null && refereeResult == null)
				gameResult = draw
			
			if (LOG.infoEnabled) {
				val finalResult = refereeResult ?: gameResult
				LOG.info('Game finished: winner = ' + finalResult.winner
						+ ', cancelationReason = ' + finalResult.cancelationReason)
			}
		}
	}
	
	def setRefereeResult(GameResult refereeResult) {
		this.refereeResult = refereeResult
		gameOver = true
	}
	
	val gameOverListener = new IRobotListener() {
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

	private def checkGameOver(IRemoteRobot robot) {
		if (robot.centerBearing.length > ARENA_OUTER_RADIUS || robot.isDead) {
			if (refereeResult == null && lastError == null) {
				if (gameResult == null || gameResult.canceled) {
					gameResult = defeat(robot.robotID)
					lastLoserTimeStamp = System.currentTimeMillis
				} else if (gameResult.winner == robot.robotID
						&& System.currentTimeMillis - lastLoserTimeStamp < GAME_LOST_THRESHOLD) {
					// Robots were losing almost simultaneously: a draw
					gameResult = draw
				}
			}
			gameOver = true
		}
	}
	
	private def checkAndRelease(IRemoteRobot.Factory robotFactory) {
		if (refereeResult == null && lastError == null && robotFactory.lastRobot != null) {
			val robot = robotFactory.newRobot(CancelIndicator.NullImpl, robotFactory.lastRobot)
			do {
				try {
					robot.waitForUpdate(SOCKET_TIMEOUT / 4)
				} catch (Exception e) {
					// Ignore exception
				}
				checkGameOver(robot)
			} while (gameResult != null && gameResult.winner == robotFactory.robotID
					&& System.currentTimeMillis - lastLoserTimeStamp < GAME_LOST_THRESHOLD)
		}
		robotFactory.release
	}
	
	static ThreadGroup threadGroup
	
	private static synchronized def getThreadGroup() {
		if (threadGroup == null) {
			threadGroup = new ThreadGroup("Robots")
		}
		threadGroup
	}
	
	public def waitThreadsTermination() {
		val threads = <Thread>newArrayOfSize(16)
		getThreadGroup.enumerate(threads)
		threads.filter[it instanceof RobotThread].forEach[join]
	}

	private def prepareScriptRunner(Program program, IRemoteRobot.Factory robotFactory, IRobotListener... listeners) {
		if (program == null) {
			throw new IllegalStateException("No program is assigned to player slot " + robotFactory.robotID)
		}
		val scriptExecutor = scriptRunnerProvider.get
		listeners.forEach[scriptExecutor.addRobotListener(it)]
		new RobotThread(getThreadGroup, robotFactory.robotID.name) {
			override run() {
				if (!robotFactory.isAlive)
					throw new IllegalStateException(robotFactory.robotID + ' robot not ready')
				try {
					scriptExecutor.run(
						program,
						robotFactory,
						[gameOver])
				} catch (CameraTimeoutException cte) {
					LOG.info(cte.message)
					if (gameResult == null)
						gameResult = canceled('Camera dropped out for ' + cte.robotID + ' robot')
				} catch (SocketTimeoutException ste) {
					LOG.warn(ste.message)
					gameResult = canceled('Connection to ' + robotFactory.robotID + ' robot was lost')
					lastError = ste
				} catch (SocketException se) {
					LOG.warn(se.message)
					gameResult = canceled('Connection to ' + robotFactory.robotID + ' robot was lost')
					lastError = se
				} catch (MemoryException me) {
					LOG.warn('Caught memory exception.', me)
					gameResult = canceled(robotFactory.robotID + ': ' + me.message)
					lastError = me
				} catch (SecurityException se) {
					LOG.warn('Caught security exception.', se)
					gameResult = canceled(program.name + ' (' + robotFactory.robotID + ')' + ' was caught cheating')
					lastError = se
				} catch (Exception e) {
					if (Throwables.getRootCause(e) instanceof SecurityException) {
						LOG.warn('Caught security exception.', e)
						gameResult = canceled(program.name + ' (' + robotFactory.robotID + ')' + ' was caught cheating')
						lastError = Throwables.getRootCause(e)
					} else {
						LOG.error('Error during robot execution', e)
						gameResult = canceled('An error occurred')
						lastError = e
					}
				} catch (OutOfMemoryError err) {
					LOG.error('Out of memory')
					lastError = new MemoryException("Heap memory limit exceeded", err)
					gameResult = canceled(lastError.message)
				} catch (Throwable t) {
					LOG.error('Error during robot execution', t)
					gameResult = canceled('An error occurred')
					lastError = t
				}
				gameOver = true
			}
		}
	}
	
	private def getTimer() {
		new Thread([
			val endTime = System.currentTimeMillis + gameDuration
			var long left = 0
			do {
				Thread.sleep(1000)
				left = max(0, endTime - System.currentTimeMillis)
				timeListener.updateTime(left)
			} while(left > 0 && !gameOver)
			gameOver = true
		], 'XRobot Timer') => [
			daemon = true
		]
	}

}
