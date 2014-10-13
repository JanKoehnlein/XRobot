package org.xtext.xrobot.game.tests

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.game.tests.di.MockUiTestModule

import static org.junit.Assert.*
import static org.hamcrest.CoreMatchers.instanceOf

@RunWith(XtextRunner)
@InjectWith(MockUiTestModule.InjectorProvider)
class SecurityTest {
	
	@Inject Provider<Game> gameProvider

	@Inject PlayerSlot.Factory playerSlotFactory
	
	List<PlayerSlot> slots
	
	@Before
	def void init() {
		slots = playerSlotFactory.createAll
	}
	
	@Test
	def void testFileRead() {
		val game = gameProvider.get()
		slots.get(0).acquire('''
			robot Test author Test
			Evil {
				say(new java.io.FileReader("/bin/kill").read().toString)
			}
		''')
		slots.get(1).acquire(TestScripts.IDLE)
		
		game.play(slots)
		assertTrue(game.gameResult.canceled)
		assertThat(game.lastError, instanceOf(SecurityException))
		assertNull(System.securityManager)
		
		slots.forEach[release]
	}
	
}