/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.di

import org.xtext.xrobot.RobotID
import org.xtext.xrobot.server.IRemoteRobot
import com.google.common.base.Predicate
import com.google.common.base.Predicates
import org.eclipse.xtend.lib.annotations.Accessors
import com.google.inject.Singleton

@Singleton
class MockRobotConnector implements IRemoteRobot.Connector {
	
	@Accessors(PUBLIC_SETTER)
	Predicate<MockRobot> deadPredicate = Predicates.alwaysFalse
	
	@Accessors(PUBLIC_SETTER)
	Predicate<MockRobot> blindPredicate = Predicates.alwaysFalse
	
	override getRobotFactory(RobotID robotID) {
		new MockRobotFactory(robotID, deadPredicate, blindPredicate)
	}
	
}