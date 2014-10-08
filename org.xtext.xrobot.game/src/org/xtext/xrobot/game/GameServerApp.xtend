package org.xtext.xrobot.game

import javafx.application.Application
import javafx.scene.text.Font
import javafx.stage.Stage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.impl.BinaryGrammarResourceFactoryImpl
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup
import org.eclipse.xtext.xbase.XbaseStandaloneSetup
import com.google.inject.Module
import org.xtext.xrobot.dsl.XRobotDSLRuntimeModule
import com.google.inject.Guice

class GameServerApp extends Application {

	public static Module gameModule = new XRobotModule

	def static void main(String[] args) {
		launch()
	}
	
	GameServer gameServer
	
	override init() throws Exception {
		super.init()
		Font.loadFont(class.getResourceAsStream('/fonts/flipside.ttf'), 24)
		Font.loadFont(class.getResourceAsStream('/fonts/Robotica.ttf'), 24)
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
