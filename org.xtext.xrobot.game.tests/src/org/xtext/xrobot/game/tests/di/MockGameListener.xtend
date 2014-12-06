/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import org.xtext.xrobot.game.IGameListener
import org.xtext.xrobot.game.Game
import javafx.stage.Stage
import java.util.List
import org.xtext.xrobot.game.PlayerSlot

class MockGameListener implements IGameListener {
	
	override prepareGame(Game game) {
		println("# game preparation")
	}

	override gameFinished(Game game) {
		println("# game finished")
	}
	
	override gameStarted(Game game) {
		println("# game started")
	}
	
	override start(Stage stage, List<PlayerSlot> slots) {
	}
}