/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.game

import com.google.inject.Guice
import com.google.inject.Module
import javafx.application.Application
import javafx.stage.Stage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.eclipse.xtext.xbase.XbaseStandaloneSetup
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup

class GameServerLauncher extends Application {

	public static Module gameModule = new XRobotModule

	def static void main(String[] args) {
		launch()
	}
	
	GameServer gameServer
	
	override init() throws Exception {
		super.init()
		Resource.Factory.Registry.INSTANCE.extensionToFactoryMap.put('xtextbin', new BinaryGrammarResourceFactoryImpl())
		XbaseStandaloneSetup.doSetup()
		val injector = Guice.createInjector(gameModule, new XRobotDSLRuntimeModule)
		new XRobotDSLStandaloneSetup().register(injector)
		gameServer = injector.getInstance(GameServer)
	}

	override start(Stage primaryStage) throws Exception {
		gameServer.start(primaryStage)
	}

}
