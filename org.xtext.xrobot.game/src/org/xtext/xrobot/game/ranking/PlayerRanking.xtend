package org.xtext.xrobot.game.ranking

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

@Accessors(PUBLIC_GETTER)
@FinalFieldsConstructor
class PlayerRanking implements Comparable<PlayerRanking> {

	val String id
	
	@Accessors
	String name
	
	@Accessors
	String author
	
	int wins
	
	int draws
	
	int defeats
	
	@Accessors
	double score
	
	new(String id, String name, String author) {
		this.id = id
		this.name = name
		this.author = author
	}
	
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

