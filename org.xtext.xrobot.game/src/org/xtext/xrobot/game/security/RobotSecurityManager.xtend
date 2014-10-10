package org.xtext.xrobot.game.security

import java.lang.SecurityManager
import java.security.Permission
import java.io.FilePermission

class RobotSecurityManager extends SecurityManager {
	
	static synchronized def install(ThreadGroup robotThreadGroup) {
		val currentManager = System.securityManager
		val newManager = new RobotSecurityManager(robotThreadGroup, currentManager)
		System.securityManager = newManager
	}
	
	static synchronized def release() {
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			val robotManager = currentManager as RobotSecurityManager
			System.securityManager = robotManager.defaultManager
		}
	}
	
	static val ALLOWED_PACKAGES = #[
		'java.lang',
		'java.util',
		'org.xtext.xrobot.api',
		'org.xtext.xrobot.game'
	]
	
	val ThreadGroup robotThreadGroup
	
	val SecurityManager defaultManager
	
	new(ThreadGroup robotThreadGroup, SecurityManager defaultManager) {
		this.robotThreadGroup = robotThreadGroup
		this.defaultManager = defaultManager
		if (robotThreadGroup == null)
			throw new NullPointerException
	}
	
	private def granted(Permission perm) {
		// Allow the class loader to read class files
		classLoaderWorking && perm instanceof FilePermission && perm.actions == 'read'
	}
	
	private def classLoaderWorking() {
		for (clazz : classContext) {
			if (ClassLoader.isAssignableFrom(clazz))
				return true
			else if (clazz != getClass
					&& !clazz.name.startsWith('java.')
					&& !clazz.name.startsWith('sun.'))
				return false
		}
		false
	}
	
	override checkPermission(Permission perm) {
		if (Thread.currentThread.threadGroup == robotThreadGroup) {
			if (!perm.granted)
				throw new SecurityException("Permission denied: " + perm)
		} else if (defaultManager != null) {
			defaultManager.checkPermission(perm)
		}
	}
	
	override checkPermission(Permission perm, Object context) {
		if (Thread.currentThread.threadGroup == robotThreadGroup) {
			if (!perm.granted)
				throw new SecurityException("Permission denied: " + perm)
		} else if (defaultManager != null) {
			defaultManager.checkPermission(perm, context)
		}
	}
	
	override checkPackageAccess(String pkg) {
		if (Thread.currentThread.threadGroup == robotThreadGroup) {
			if (!ALLOWED_PACKAGES.contains(pkg)) {
				throw new SecurityException("Package not allowed: " + pkg)
			}
		} else {
			super.checkPackageAccess(pkg)
		}
	}
	
	override checkPackageDefinition(String pkg) {
		println("package definition: " + pkg)
		super.checkPackageDefinition(pkg)
	}
	
}