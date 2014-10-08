package org.xtext.xrobot.game.tests

import com.google.inject.Guice
import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.eclipse.xtext.xbase.XbaseStandaloneSetup
import org.junit.Before
import org.junit.Test
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.PlayerSlot

import static org.junit.Assert.*
import static org.xtext.xrobot.game.PlayerStatus.*

class GameTest {
	
	@Inject Provider<Game> gameProvider

	@Inject PlayerSlot.Factory playerSlotFactory

	List<PlayerSlot> slots
	
	@Before
	def void init() {
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		XbaseStandaloneSetup.doSetup()
		val injector = Guice.createInjector(new XRobotTestModule, new XRobotDSLRuntimeModule)
		new XRobotDSLStandaloneSetup().register(injector)
		injector.injectMembers(this)

		slots = playerSlotFactory.createAll
	}
	
	@Test
	def void testDraw() {
		val game = gameProvider.get()
		game.gameDuration = 1000
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		
		game.play(slots)
		assertNull(game.loser)
		
		slots.forEach[release]
	}
	
//	@Test
	def void testDeath() {
		val game = gameProvider.get()
		slots.forEach[
			acquire(ITestScripts.IDLE)
			status = FIGHTING
		]
		// TODO configure robot connector such that a death is simulated
		
		game.play(slots)
		assertEquals(game.loser, RobotID.Blue)
		
		slots.forEach[release]
	}
	
}