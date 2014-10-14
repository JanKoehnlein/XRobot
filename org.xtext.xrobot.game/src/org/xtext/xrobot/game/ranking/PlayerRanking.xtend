package org.xtext.xrobot.game.ranking

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@Accessors(PUBLIC_GETTER)
@FinalFieldsConstructor
class PlayerRanking implements Comparable<PlayerRanking> {

	val String id
	val String name
	int wins
	int draws
	int defeats
	
	@Accessors
	double score 
	
	def addWin() {
		wins++
	}
	
	def addDraw() {
		draws++
	}
	
	def addDefeat() {
		defeats++
	}
	
	def getNumGames() {
		wins + draws + defeats
	}

	override compareTo(PlayerRanking other) {
		other.score.compareTo(score)
	}
}

