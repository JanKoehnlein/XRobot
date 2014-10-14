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
	
	private def performSecurityTest(String evilProgram) {
		val game = gameProvider.get()
		slots.get(0).acquire(evilProgram)
		slots.get(1).acquire(TestScripts.IDLE)
		
		game.play(slots)
		assertTrue(game.gameResult.canceled)
		assertThat(game.lastError, instanceOf(SecurityException))
		
		game.waitThreadsTermination
		assertNull(System.securityManager)
		slots.forEach[release]
	}
	
	@Test
	def void testFileRead() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				say(new java.io.FileReader("/bin/kill").read().toString)
			}
		''')
	}
	
	@Test
	def void testFileWrite() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				new java.io.FileWriter("/tmp/output").write("i kill u")
			}
		''')
	}
	
	@Test
	def void testExit() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				System.exit(0)
			}
		''')
	}
	
	@Test
	def void testThreadCreate() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				new Thread[while(true){}].start
			}
		''')
	}
	
	@Test
	def void testVariableInitializer() {
		performSecurityTest('''
			robot Test author Test
			var evil = new java.io.FileWriter("/tmp/output")
		''')
	}
	
	@Test
	def void testModeCondition() {
		performSecurityTest('''
			robot Test author Test
			Evil on (new java.io.FileWriter("/tmp/output") != null) {}
		''')
	}
	
}