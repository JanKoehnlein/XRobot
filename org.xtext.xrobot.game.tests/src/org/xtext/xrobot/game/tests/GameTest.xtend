package org.xtext.xrobot.game.tests

import org.junit.Test
import org.junit.Before
import java.util.List
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.RobotID
import com.google.inject.Inject
import com.google.inject.Provider
import static org.xtext.xrobot.game.PlayerStatus.*
import org.xtext.xrobot.game.Game
import static org.junit.Assert.*
import org.xtext.xrobot.dsl.interpreter.ScriptParser
import org.eclipse.xtext.resource.XtextResourceSet
import org.xtext.xrobot.game.ITestScripts
import org.xtext.xrobot.server.testing.MockRobotConnector
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup

class GameTest {
	
	@Inject Provider<Game> gameProvider
	@Inject Provider<MockRobotPreparer> robotPreparerProvider
	@Inject Provider<XtextResourceSet> resourceSetProvider
	@Inject MockRobotConnector remoteRobotConnector
	@Inject ScriptParser scriptParser
	
	List<PlayerSlot> slots
	
	@Before
	def void prepare() {
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		new XRobotDSLStandaloneSetup().createInjectorAndDoEMFRegistration.injectMembers(this)
		slots = #[
			new PlayerSlot(RobotID.Blue, remoteRobotConnector, null, robotPreparerProvider),
			new PlayerSlot(RobotID.Red, remoteRobotConnector, null, robotPreparerProvider)
		]
	}
	
	@Test
	def void testDraw() {
		val resourceSet = resourceSetProvider.get
		val idleScript = scriptParser.parse(ITestScripts.IDLE, resourceSet)
		slots.get(0).acquire(idleScript)
		slots.get(1).acquire(idleScript)
		val game = gameProvider.get()
		game.gameDuration = 1000
		slots.forEach[status = FIGHTING]
		
		game.play(slots)
		assertNull(game.loser)
		
		slots.forEach[release]
	}
	
}