/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game.tests.ranking

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.junit.Test
import org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLFactory
import org.xtext.xrobot.game.ranking.RankingProvider

import static org.junit.Assert.*

class RankingTest {
	
	extension RankingProvider = new RankingProvider
	
	@Test
	def void testPersistence() {
		clear
		val foo = createProgram('foo.xrobot', 'Foo')
		val bar = createProgram('bar.xrobot', 'Bar')
		foo.ranking.score = 20
		bar.ranking.addWin
		save

		val r = new RankingProvider()
		val hallOfFame = r.hallOfFame
		assertEquals(2, hallOfFame.size)
		assertEquals(20, r.getRanking(foo).score as int)
		assertEquals(1, r.getRanking(bar).wins)
	}
	
	def createProgram(String uri, String name) {
		val resource = new XMIResourceImpl(URI.createURI(uri))
		val program = XRobotDSLFactory.eINSTANCE.createProgram => [
			it.name = name
			it.author = 'test'
		]
		resource.contents += program
		program
	}
	 
}