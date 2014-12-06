/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import org.eclipse.xtend.lib.annotations.Data
import org.xtext.xrobot.RobotID

@Data
class GameResult {
	
	static def win(RobotID id) {
		new GameResult(id, null, false)
	}
	
	static def defeat(RobotID id) {
		new GameResult(id.opponent, null, false)	
	}
	
	static def draw() {
		new GameResult(null, null, false)
	}
	
	static def canceled(String cancelationReason) {
		new GameResult(null, cancelationReason, false)
	}
	
	static def replay() {
		new GameResult(null, null, true)
	}
	
	val RobotID winner
	val String cancelationReason
	val boolean replay
	
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