package org.xtext.xrobot.game.tests.ranking

import org.junit.Test
import org.xtext.xrobot.game.ranking.RankingProvider

import static org.junit.Assert.*

class RankingTest {
	
	extension RankingProvider = new RankingProvider
	
	@Test
	def void testPersistence() {
		'foo'.ranking.score = 20
		'bar'.ranking.addWin
		save

		val r = new RankingProvider()
		val hallOfFame = r.hallOfFame
		assertEquals(2, hallOfFame.size)
		assertEquals(20, r.getRanking('foo').score as int)
		assertEquals(1, r.getRanking('bar').wins)
	}
}