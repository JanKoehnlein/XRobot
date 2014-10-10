package org.xtext.xrobot.game.tests

import com.google.common.base.Predicates
import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.game.tests.di.MockRobotConnector
import org.xtext.xrobot.game.tests.di.MockUiTestModule

import static org.junit.Assert.*
import static org.xtext.xrobot.game.PlayerStatus.*

@RunWith(XtextRunner)
@InjectWith(MockUiTestModule.InjectorProvider)
class GameTest {
	
	@Inject Provider<Game> gameProvider

	@Inject PlayerSlot.Factory playerSlotFactory
	
	@Inject MockRobotConnector mockRobotConnector

	List<PlayerSlot> slots
	
	@Before
	def void init() {
		slots = playerSlotFactory.createAll
	}
	
	@Test
	def void testDraw() {
		mockRobotConnector.deadPredicate = Predicates.alwaysFalse
		mockRobotConnector.blindPredicate = Predicates.alwaysFalse
		val game = gameProvider.get()
		game.gameDuration = 1000
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertTrue(game.gameResult.isDraw)
		
		slots.forEach[release]
	}
	
	@Test
	def void testDeath() {
		mockRobotConnector.deadPredicate = [
			robotID == RobotID.Blue && age > 1500
		]
		mockRobotConnector.blindPredicate = Predicates.alwaysFalse
		val game = gameProvider.get()
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertEquals(RobotID.Red, game.gameResult.winner)
		assertEquals(RobotID.Blue, game.gameResult.loser)
		
		slots.forEach[release]
	}
	
	@Test
	def void testCameraLoss() {
		mockRobotConnector.deadPredicate = Predicates.alwaysFalse
		mockRobotConnector.blindPredicate = [
			robotID == RobotID.Blue && age > 1000
		]
		val game = gameProvider.get()
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertTrue(game.gameResult.isCanceled)
		assertNotNull(game.gameResult.cancelationReason)
		
		slots.forEach[release]
	}
	
	@Test
	def void testDeathWithCameraLoss() {
		mockRobotConnector.deadPredicate = [
			robotID == RobotID.Blue && age > 1000
		]
		mockRobotConnector.blindPredicate = [
			robotID == RobotID.Blue && age > 500
		]
		val game = gameProvider.get()
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertEquals(RobotID.Red, game.gameResult.winner)
		assertEquals(RobotID.Blue, game.gameResult.loser)
		
		slots.forEach[release]
	}
	
	@Test
	def void testSimultaneousDeath() {
		mockRobotConnector.deadPredicate = [
			switch (robotID) {
				case Blue: {
					age > 1200
				}
				case Red: {
					age > 1500
				}
			}
		]
		mockRobotConnector.blindPredicate = Predicates.alwaysFalse
		val game = gameProvider.get()
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertTrue(game.gameResult.isDraw)
		
		slots.forEach[release]
	}
	
	@Test
	def void testSimultaneousDeathWithCameraLoss() {
		mockRobotConnector.deadPredicate = [
			switch (robotID) {
				case Blue: {
					age > 1000
				}
				case Red: {
					age > 1200
				}
			}
		]
		mockRobotConnector.blindPredicate = [
			switch (robotID) {
				case Blue: {
					age > 500
				}
				case Red: {
					age > 1000
				}
			}
		]
		val game = gameProvider.get()
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertTrue(game.gameResult.isDraw)
		
		slots.forEach[release]
	}
	
}