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
		assertEquals(game.gameResult.winner, RobotID.Red)
		assertEquals(game.gameResult.loser, RobotID.Blue)
		
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
	
}