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