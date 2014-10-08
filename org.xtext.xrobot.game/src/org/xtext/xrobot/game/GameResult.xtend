package org.xtext.xrobot.game

import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.RobotID

@Data
class GameResult {
	
	static def win(RobotID id) {
		new GameResult(id, null)
	}
	
	static def defeat(RobotID id) {
		new GameResult(id.opponent, null)	
	}
	
	static def draw() {
		new GameResult(null, null)
	}
	
	static def canceled(String cancelationReason) {
		new GameResult(null, cancelationReason)
	}
	
	RobotID winner
	String cancelationReason
	
	def RobotID getLoser() {
		winner?.opponent
	}
	
	def isDraw() {
		winner == null && !isCanceled
	}
	
	def isCanceled() {
		cancelationReason != null
	}
}