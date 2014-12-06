/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import org.eclipse.xtend.lib.annotations.Accessors
import org.xtext.xrobot.game.IRobotPreparer
import org.xtext.xrobot.game.PlayerSlot

import static org.xtext.xrobot.game.PlayerStatus.*

class MockRobotPreparer implements IRobotPreparer {
	
	@Accessors(PUBLIC_SETTER)
	PlayerSlot slot
	
	override prepare() {
		synchronized (slot) {
			if (slot.status != READY)
				slot.status = PREPARING
		}
	}
	
	override waitReady() {
		synchronized (slot) {
			if (!slot.available)
				slot.status = READY
		}
	}
	
	override cancel() {
	}
	
}