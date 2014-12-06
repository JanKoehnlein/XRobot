/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import java.util.List
import javafx.stage.Stage

interface IGameListener {
	
	def void start(Stage stage, List<PlayerSlot> slots)
	
	def void prepareGame(Game game)
	
	def void gameStarted(Game game)

	def void gameFinished(Game game)
}