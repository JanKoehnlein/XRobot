package org.xtext.xrobot.dsl.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.xtext.mindstorms.xrobot.api.IRobot
import org.xtext.xrobot.dsl.xRobotDSL.Program

/**
 * <p>Infers a JVM model from the source model.</p> 
 *
 * <p>The JVM model should contain all elements that would appear in the Java code 
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>     
 */
class XRobotDSLJvmModelInferrer extends AbstractModelInferrer {

	@Inject extension JvmTypesBuilder

   	def dispatch void infer(Program program, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
   		acceptor
   			.accept(program.toClass("org.xtext.xrobot.dsl." + program.name))
   			.initializeLater [
   				for (sub : program.subs) {
   					members += sub.toMethod(sub.name, sub.body.inferredType) [
   						parameters += sub.parameters.map [ toParameter(name, parameterType) ]
   						body = sub.body
   					]
   				}
   				val main = program.main
   				members += main.toMethod('main', null) [
   					parameters += main.toParameter('it', main.newTypeRef(IRobot))
   					body = main.body
   				]
   			]
   	}
}

