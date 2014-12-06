/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests

import com.google.inject.Inject
import com.google.inject.Provider
import java.util.List
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.xtext.xrobot.dsl.interpreter.MemoryException
import org.xtext.xrobot.game.Game
import org.xtext.xrobot.game.PlayerSlot
import org.xtext.xrobot.game.tests.di.MockUiTestModule

import static org.hamcrest.CoreMatchers.instanceOf
import static org.junit.Assert.*

@RunWith(XtextRunner)
@InjectWith(MockUiTestModule.InjectorProvider)
class SecurityTest {
	
	@Inject Provider<Game> gameProvider

	@Inject PlayerSlot.Factory playerSlotFactory
	
	List<PlayerSlot> slots
	
	@Before
	def void init() {
		slots = playerSlotFactory.createAll
		slots.forEach[scriptParser.validate = false]
	}
	
	private def performSecurityTest(String evilProgram) {
		val game = gameProvider.get()
		slots.get(0).acquire('evil.xrobot', evilProgram)
		slots.get(1).acquire('idle.xrobot', TestScripts.IDLE)
		
		game.play(slots)
		assertTrue(game.gameResult.canceled)
		assertThat(game.lastError, instanceOf(SecurityException))
		
		game.waitThreadsTermination
		assertNull(System.securityManager)
		slots.forEach[release]
	}
	
	@Test
	def void testFileRead() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				say(new java.io.FileReader("/bin/kill").read().toString)
			}
		''')
	}
	
	@Test
	def void testFileWrite() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				new java.io.FileWriter("/tmp/output").write("i kill u")
			}
		''')
	}
	
	@Test
	def void testFileDelete() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				new java.io.File("/tmp/dummy").delete
			}
		''')
	}
	
	@Test
	def void testExit() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				System.exit(0)
			}
		''')
	}
	
	@Test
	def void testChangeSecurityManager() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				System.setSecurityManager(null)
			}
		''')
	}
	
	@Test
	def void testDeactivateSecurityManager() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				org.xtext.xrobot.dsl.interpreter.security.RobotSecurityManager.deactivate(0xdeadbeef)
			}
		''')
	}
	
	@Test
	def void testReflection() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				val thread = Thread.getMethod('currentThread').invoke(null) as Thread
				val tokenMap = org.xtext.xrobot.dsl.interpreter.security.RobotSecurityManager
					.getField('deactivationTokens').get(System.securityManager) as java.util.HashMap<Thread, Long>
				org.xtext.xrobot.dsl.interpreter.security.RobotSecurityManager.getMethod('deactivate', long)
					.invoke(System.securityManager, tokenMap.get(thread))
			}
		''')
	}
	
	@Test
	def void testThreadCreate() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				new Thread[while(true){}].start
			}
		''')
	}
	
	@Test
	def void testExecute() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				Runtime.runtime.exec(#['/bin/rm', '/tmp/*'])
			}
		''')
	}
	
	@Test
	def void testVariableInitializer() {
		performSecurityTest('''
			robot Test author Test
			var evil = new java.io.FileWriter("/tmp/output")
		''')
	}
	
	@Test
	def void testModeCondition() {
		performSecurityTest('''
			robot Test author Test
			Evil on (new java.io.FileWriter("/tmp/output") != null) {}
		''')
	}
	
	@Test
	def void testSocket() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				val socket = new java.net.Socket()
				socket.connect(new java.net.InetSocketAddress("www.google.com", 80))
			}
		''')
	}
	
	@Test
	def void testSocketChannel() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				val socket = java.nio.channels.SocketChannel.open()
				socket.connect(new java.net.InetSocketAddress("www.google.com", 80))
			}
		''')
	}
	
	@Test
	def void testDatagramSocket() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				val buf = newByteArrayOfSize(1024)
				new java.net.DatagramSocket().receive(new java.net.DatagramPacket(buf, 1024))
			}
		''')
	}
	
	@Test
	def void testServerSocket() {
		performSecurityTest('''
			robot Test author Test
			Evil {
				new java.net.ServerSocket().bind(new java.net.InetSocketAddress("127.0.0.1", 80))
			}
		''')
	}
	
	@Test
	def void testSwing() {
		performSecurityTest('''
			robot Test author Test
			var init = true
			Evil on init {
				val frame = new javax.swing.JFrame("Dr. Evil")
				frame.getContentPane().add(new javax.swing.JLabel("Hahaha!"))
				frame.pack()
				frame.setVisible(true)
				init = false
			}
		''')
	}
	
	private def performMemoryTest(String evilProgram) {
		val game = gameProvider.get()
		slots.get(0).acquire('evil.xrobot', evilProgram)
		slots.get(1).acquire('idle.xrobot', TestScripts.IDLE)
		
		game.play(slots)
		assertTrue(game.gameResult.canceled)
		assertThat(game.lastError, instanceOf(MemoryException))
		
		slots.forEach[release]
	}
	
	@Test
	def testRecursionLimit() {
		performMemoryTest('''
			robot Test author Test
			Evil {
				recurse
			}
			def void recurse() {
				recurse
			}
		''')
	}
	
	@Test
	def testArraySizeLimit() {
		performMemoryTest('''
			robot Test author Test
			Evil {
				val a = newIntArrayOfSize(10000000)
			}
		''')
	}
	
	@Test
	def testFreeMemoryLimit() {
		performMemoryTest('''
			robot Test author Test
			Evil {
				val list = newLinkedList
				while (true) {
					list.add(newDoubleArrayOfSize(4096))
				}
			}
		''')
	}
	
}