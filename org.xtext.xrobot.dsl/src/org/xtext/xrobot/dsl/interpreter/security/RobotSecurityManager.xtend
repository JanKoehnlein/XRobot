package org.xtext.xrobot.dsl.interpreter.security

import java.io.FilePermission
import java.security.AccessController
import java.security.Permission

import static java.lang.System.*
import java.util.PropertyPermission
import java.util.List
import java.lang.reflect.ReflectPermission
import java.util.HashMap
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter

class RobotSecurityManager extends SecurityManager {
	
	static synchronized def start() {
		var RobotSecurityManager robotManager
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			robotManager = currentManager as RobotSecurityManager
		} else {
			robotManager = new RobotSecurityManager(currentManager)
			System.securityManager = robotManager
		}
		synchronized (robotManager.activeThreads) {
			robotManager.activeThreads.put(Thread.currentThread, false)
		}
	}
	
	static synchronized def stop() {
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			val robotManager = currentManager as RobotSecurityManager
			synchronized (robotManager.activeThreads) {
				robotManager.activeThreads.remove(Thread.currentThread)
				if (robotManager.activeThreads.empty) {
					System.securityManager = robotManager.defaultManager
				}
			}
		} else {
			throw new IllegalStateException("Robot security manager is not installed.")
		}
	}
	
	static synchronized def setActive(boolean active) {
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			val robotManager = currentManager as RobotSecurityManager
			synchronized (robotManager.activeThreads) {
				robotManager.activeThreads.put(Thread.currentThread, active)
			}
		} else {
			throw new IllegalStateException("Robot security manager is not installed.")
		}
	}
	
	static val ALLOWED_PACKAGES = #[
		'java.lang',
		'java.lang.reflect',
		'java.lang.invoke',
		'java.util',
		'java.util.concurrent',
		'java.util.concurrent.atomic',
		'java.io',
		'java.net',
		'java.security',
		'javafx.scene.media',
		'sun.misc',
		'sun.reflect',
		'com.google.common.base',
		'com.google.common.collect',
		'org.apache.log4j.spi',
		'org.xtext.xrobot*',
		'org.eclipse.xtext*'
	]
	
	static val ALLOWED_PROPERTIES = #[
		'line.separator',
		'sun.invoke.util.ValueConversions.MAX_ARITY'
	]
	
	static def containedIn(String searchString, List<String> list) {
		for (String s : list) {
			if (s == searchString || s.endsWith('*')
					&& searchString.startsWith(s.substring(0, s.length - 1))) {
				return true
			}
		}
		false
	}
	
	val activeThreads = new HashMap<Thread, Boolean>
	
	val SecurityManager defaultManager
	
	new(SecurityManager defaultManager) {
		this.defaultManager = defaultManager
	}
	
	private def isActiveThread() {
		synchronized (activeThreads) {
			activeThreads.get(Thread.currentThread) ?: false
		}
	}
	
	private def granted(Permission perm) {
		try {
			switch (perm.class) {
				case FilePermission: {
					classLoaderWorking && perm.actions == 'read'
				}
				case PropertyPermission: {
					ALLOWED_PROPERTIES.contains(perm.name) && perm.actions == 'read'
				}
				case RuntimePermission: {
					perm.name == 'accessDeclaredMembers'
					|| perm.name == 'createClassLoader' && (interpreterWorking || injectorWorking)
				}
				case ReflectPermission: {
					perm.name == 'suppressAccessChecks' && (interpreterWorking || injectorWorking || utilWorking)
				}
				default: false
			}
		} catch (Throwable t) {
			false
		}
	}
	
	static val SECURE_CLASSES = #[
		XbaseInterpreter, RobotSecurityManager, SecurityManager, AccessController, Class,
		ClassLoader, System, java.io.File, java.io.FileInputStream, java.util.zip.ZipFile,
		java.util.jar.JarFile, java.lang.reflect.Constructor, java.lang.reflect.Method,
		java.lang.reflect.AccessibleObject
	]
	
	static val SECURE_CLASS_NAMES = #[
		'java.net.URLClassLoader',
		'sun.misc.URLClassPath',
		'sun.misc.Resource',
		'sun.misc.FileURLMapper',
		'sun.reflect.DelegatingClassLoader',
		'sun.reflect.ClassDefiner',
		'sun.reflect.MethodAccessorGenerator',
		'sun.reflect.NativeConstructorAccessorImpl',
		'sun.reflect.NativeMethodAccessorImpl',
		'sun.reflect.DelegatingConstructorAccessorImpl',
		'sun.reflect.DelegatingMethodAccessorImpl',
		'com.google.inject.internal.DefaultConstructionProxyFactory'
	]
	
	private def classLoaderWorking() {
		for (clazz : classContext) {
			var checkClass = clazz
			while (checkClass.enclosingClass != null)
				checkClass = checkClass.enclosingClass
			if (!SECURE_CLASSES.contains(checkClass) && !SECURE_CLASS_NAMES.contains(checkClass.name))
				return false
			else if (ClassLoader.isAssignableFrom(checkClass))
				return true
		}
		false
	}
	
	private def interpreterWorking() {
		for (clazz : classContext) {
			var checkClass = clazz
			while (checkClass.enclosingClass != null)
				checkClass = checkClass.enclosingClass
			if (!SECURE_CLASSES.contains(checkClass) && !SECURE_CLASS_NAMES.contains(checkClass.name))
				return false
			else if (XbaseInterpreter.isAssignableFrom(checkClass))
				return true
		}
		false
	}
	
	private def injectorWorking() {
		for (clazz : classContext) {
			var checkClass = clazz
			while (checkClass.enclosingClass != null)
				checkClass = checkClass.enclosingClass
			if (checkClass.name == 'com.google.inject.internal.ConstructorInjector')
				return true
			else if (!SECURE_CLASSES.contains(checkClass) && !SECURE_CLASS_NAMES.contains(checkClass.name))
				return false
		}
		false
	}
	
	private def utilWorking() {
		for (clazz : classContext) {
			var checkClass = clazz
			while (checkClass.enclosingClass != null)
				checkClass = checkClass.enclosingClass
			if (checkClass == java.util.EnumMap)
				return true
			else if (!SECURE_CLASSES.contains(checkClass) && !SECURE_CLASS_NAMES.contains(checkClass.name))
				return false
		}
		false
	}
	
	override checkPermission(Permission perm) {
		if (isActiveThread) {
			if (!perm.granted)
				throw new SecurityException("Permission denied: " + perm)
		} else if (defaultManager != null) {
			defaultManager.checkPermission(perm)
		}
	}
	
	override checkPermission(Permission perm, Object context) {
		if (isActiveThread) {
			if (!perm.granted)
				throw new SecurityException("Permission denied: " + perm)
		} else if (defaultManager != null) {
			defaultManager.checkPermission(perm, context)
		}
	}
	
	override checkPackageAccess(String pkg) {
		if (isActiveThread) {
			if (!pkg.containedIn(ALLOWED_PACKAGES)) {
				throw new SecurityException("Package not allowed: " + pkg)
			}
		} else {
			super.checkPackageAccess(pkg)
		}
	}
	
	override getThreadGroup() {
		// Return the top-level group in order to avoid foreign threads in our internal group
		var group = Thread.currentThread.threadGroup
		while (group?.parent != null) {
			group = group.parent
		}
		group
	}
	
}