package org.xtext.xrobot.game.tests.di

import com.google.common.base.Predicate
import java.net.SocketTimeoutException
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.camera.CameraTimeoutException
import org.xtext.xrobot.server.IRemoteRobot

@Accessors
class MockRobotFactory implements IRemoteRobot.Factory {
	
	val RobotID robotID
	
	val Predicate<MockRobot> deadPredicate
	
	val Predicate<MockRobot> blindPredicate
	
	@Accessors(PUBLIC_GETTER)
	var MockRobot lastRobot
	
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
	
	override newRobot(CancelIndicator cancelIndicator) throws SocketTimeoutException, CameraTimeoutException {
		lastRobot = new MockRobot(robotID, cancelIndicator, deadPredicate, blindPredicate)
	}
	
	override newRobot(CancelIndicator cancelIndicator, IRemoteRobot existingRobot) {
		lastRobot = new MockRobot(robotID, cancelIndicator, deadPredicate, blindPredicate)
		lastRobot.setState(existingRobot as MockRobot)
		lastRobot
	}
	
}