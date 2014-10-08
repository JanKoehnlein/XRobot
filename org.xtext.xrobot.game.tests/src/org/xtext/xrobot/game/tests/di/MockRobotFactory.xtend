package org.xtext.xrobot.game.tests.di

import java.net.SocketTimeoutException
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.server.IRemoteRobot
import com.google.common.base.Predicate

@Accessors
class MockRobotFactory implements IRemoteRobot.Factory {
	
	val RobotID robotID
	
	val Predicate<MockRobot> deadPredicate
	
	val Predicate<MockRobot> blindPredicate
	
	@Accessors(NONE)
	var boolean isReleased

	override release() {
		isReleased = true
	}
	
	override reset() {
	}
	
	override isAlive() {
		!isReleased
	}
	
	override newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException {
		new MockRobot(robotID, cancelIndicator, deadPredicate, blindPredicate)
	}
	
	override newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot) {
		val newRobot = new MockRobot(robotID, cancelIndicator, deadPredicate, blindPredicate)
		newRobot.setState(existingRobot as MockRobot)
		newRobot
	}
	
}