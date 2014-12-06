/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.interpreter.security

import java.io.File
import java.io.FileInputStream
import java.io.FilePermission
import java.lang.reflect.AccessibleObject
import java.lang.reflect.Constructor
import java.lang.reflect.Method
import java.lang.reflect.ReflectPermission
import java.security.AccessController
import java.security.Permission
import java.security.SecureRandom
import java.util.Collection
import java.util.EnumMap
import java.util.HashMap
import java.util.Properties
import java.util.PropertyPermission
import java.util.PropertyResourceBundle
import java.util.ResourceBundle
import java.util.jar.JarFile
import java.util.zip.ZipFile
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.util.PolymorphicDispatcher
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter

import static java.lang.System.*

/**
 * The security manager for the XRobot interpreter.
 */
class RobotSecurityManager extends SecurityManager {
	
	static val random = new SecureRandom
	
	/**
	 * Start the security manager for the current thread. The security manager is initially
	 * inactive.
	 */
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
	
	/**
	 * Stop the security manager for the current thread.
	 */
	static synchronized def stop() {
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			val robotManager = currentManager as RobotSecurityManager
			synchronized (robotManager.activeThreads) {
				if (robotManager.activeThreads.get(Thread.currentThread)) {
					throw new SecurityException("Security manager is still active.")
				}
				robotManager.activeThreads.remove(Thread.currentThread)
				if (robotManager.activeThreads.empty) {
					System.securityManager = robotManager.defaultManager
				}
			}
		} else {
			throw new IllegalStateException("Robot security manager is not installed.")
		}
	}
	
	/**
	 * Activate the security manager for the current thread. The returned token number is
	 * required to deactivate the security manager.
	 */
	static synchronized def activate() {
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			val robotManager = currentManager as RobotSecurityManager
			val thread = Thread.currentThread
			val token = random.nextLong
			synchronized (robotManager.activeThreads) {
				robotManager.activeThreads.put(thread, true)
				robotManager.deactivationTokens.put(thread, token)
			}
			return token
		} else {
			throw new IllegalStateException("Robot security manager is not installed.")
		}
	}
	
	/**
	 * Deactivate the security manager for the current thread.
	 */
	static synchronized def deactivate(long token) {
		val currentManager = System.securityManager
		if (currentManager instanceof RobotSecurityManager) {
			val robotManager = currentManager as RobotSecurityManager
			val thread = Thread.currentThread
			synchronized (robotManager.activeThreads) {
				if (robotManager.deactivationTokens.get(thread) != token) {
					throw new SecurityException
				}
				robotManager.activeThreads.put(thread, false)
			}
			return token
		} else {
			throw new IllegalStateException("Robot security manager is not installed.")
		}
	}
	
	/**
	 * Packages for which access is allowed through the XRobot API.
	 */
	public static val ALLOWED_PACKAGES = #{
		'java.lang',
		'java.util',
		'com.google.common.base',
		'com.google.common.collect',
		'org.xtext.xrobot.api',
		'org.eclipse.xtext.xbase.lib'
	}
	
	/**
	 * Packages with forbidden API access but allowed indirect access through the interpreter.
	 */
	public static val RESTRICTED_PACKAGES = #{
		'java.lang.reflect',
		'java.lang.invoke',
		'java.util.concurrent',
		'java.util.concurrent.atomic',
		'java.io',
		'java.net',
		'java.security',
		'javafx.scene.media',
		'sun.misc',
		'sun.reflect',
		'org.apache.log4j.spi',
		'org.xtext.xrobot*',
		'org.eclipse.xtext*',
		'org.eclipse.emf.ecore.util'
	}
	
	/**
	 * System properties for which access is allowed.
	 */
	public static val ALLOWED_PROPERTIES = #{
		'os.name',
		'line.separator',
		'sun.invoke.util.ValueConversions.MAX_ARITY'
	}
	
	/**
	 * Classes that are excluded from API access.
	 */
	public static val RESTRICTED_CLASSES = #{
		ClassLoader, Compiler, Process, ProcessBuilder, Runtime, SecurityManager, Thread,
		ThreadGroup, Properties, PropertyResourceBundle, ResourceBundle, RobotSecurityManager
	}
	
	static def containedIn(String searchString, Collection<String> coll) {
		if (coll.contains(searchString))
			return true
		for (String s : coll) {
			if (s.endsWith('*') && searchString.startsWith(s.substring(0, s.length - 1))) {
				return true
			}
		}
		false
	}
	
	val activeThreads = new HashMap<Thread, Boolean>

	val deactivationTokens = new HashMap<Thread, Long>
	
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
	
	static val SECURE_CLASSES = #{
		XbaseInterpreter, RobotSecurityManager, SecurityManager, AccessController, Class,
		ClassLoader, System, FilePermission, File, FileInputStream, ZipFile, JarFile,
		Constructor, Method, AccessibleObject, PolymorphicDispatcher,
		DefaultDeclarativeQualifiedNameProvider
	}
	
	static val SECURE_CLASS_NAMES = #{
		'java.net.URLClassLoader',
		'java.io.UnixFileSystem',
		'java.io.WinNTFileSystem',
		'sun.misc.URLClassPath',
		'sun.misc.Resource',
		'sun.misc.FileURLMapper',
		'sun.net.www.protocol.file.FileURLConnection',
		'sun.net.www.protocol.jar.JarFileFactory',
		'sun.net.www.protocol.jar.JarURLConnection',
		'sun.reflect.DelegatingClassLoader',
		'sun.reflect.ClassDefiner',
		'sun.reflect.MethodAccessorGenerator',
		'sun.reflect.NativeConstructorAccessorImpl',
		'sun.reflect.NativeMethodAccessorImpl',
		'sun.reflect.DelegatingConstructorAccessorImpl',
		'sun.reflect.DelegatingMethodAccessorImpl',
		'com.google.inject.internal.DefaultConstructionProxyFactory'
	}
	
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
			else if (XbaseInterpreter.isAssignableFrom(checkClass)
					|| IQualifiedNameProvider.isAssignableFrom(checkClass))
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
			if (checkClass == EnumMap)
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
			if (!pkg.containedIn(ALLOWED_PACKAGES) && !pkg.containedIn(RESTRICTED_PACKAGES)) {
				throw new SecurityException("Package not allowed: " + pkg)
			}
		} else {
			super.checkPackageAccess(pkg)
		}
	}
	
	override getThreadGroup() {
		// Return the parent group in order to avoid foreign threads in our internal group
		Thread.currentThread.threadGroup?.parent
	}
	
}