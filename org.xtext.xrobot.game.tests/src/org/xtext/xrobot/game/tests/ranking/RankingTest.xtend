package org.xtext.xrobot.game.tests.ranking

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.junit.Test
import org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLFactory
import org.xtext.xrobot.game.ranking.RankingProvider

import static org.junit.Assert.*

class RankingTest {
	
	extension RankingProvider = new RankingProvider
	
	@Test
	def void testPersistence() {
		clear
		val foo = createProgram('foo.xrobot', 'foo')
		val bar = createProgram('bar.xrobot', 'bar')
		foo.ranking.score = 20
		bar.ranking.addWin
		save

		val r = new RankingProvider()
		val hallOfFame = r.hallOfFame
		assertEquals(2, hallOfFame.size)
		assertEquals(20, r.getRanking(foo).score as int)
		assertEquals(1, r.getRanking(bar).wins)
	}
	
	def createProgram(String uri, String name) {
		val resource = new XMIResourceImpl(URI.createURI(uri))
		val program = XRobotDSLFactory.eINSTANCE.createProgram => [
			it.name = name
		]
		resource.contents += program
		program
	}
	 
}