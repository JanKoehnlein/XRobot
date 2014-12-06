/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.ranking

import com.google.inject.Inject

import static java.lang.Math.*
import org.xtext.xrobot.dsl.xRobotDSL.Program

class RankingSystem {
	
	@Inject RankingProvider rankingProvider
	
	def addWin(Program winner, Program loser) {
		val ranking1 = rankingProvider.getRanking(winner)
		val ranking2 = rankingProvider.getRanking(loser)
		updateElo(ranking1, ranking2, 1)
		ranking1.addWin
		ranking2.addDefeat
		rankingProvider.save
	}
	
	def addDraw(Program player1, Program player2) {
		val ranking1 = rankingProvider.getRanking(player1)
		val ranking2 = rankingProvider.getRanking(player2)
		updateElo(ranking1, ranking2, 0.5)
		ranking1.addDraw
		ranking2.addDraw
		rankingProvider.save
	}
	
	/** 
	 * @param points 1 if player1 won, 0.5 for a draw
	 */
	private def updateElo(PlayerRanking ranking1, PlayerRanking ranking2, double points) {
		ranking1.initialize
		ranking2.initialize
		
		val eloDiff = max(-400, min(400, ranking2.score-ranking1.score))
		val ew = 1 / (1 + pow(10, eloDiff / 400))
		val el = 1- ew
		
		ranking1.score = ranking1.score + 40 * (points - ew)
		ranking2.score = ranking2.score + 40 * (1 - points - el)
	}
	
	private def initialize(PlayerRanking ranking) {
		if(ranking.numGames == 0)
			ranking.score = 1200
	}
}