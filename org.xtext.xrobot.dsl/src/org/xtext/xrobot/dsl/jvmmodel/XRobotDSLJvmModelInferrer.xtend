package org.xtext.xrobot.dsl.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.dynamic.IScript

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
   				superTypes += newTypeRef(IScript)
   				for(field: program.fields) {
   					var fieldType = field.type ?: field.initializer.inferredType ?: field.newTypeRef(Object)  
   					members += field.toField(field.name, fieldType) [
   						initializer = field.initializer
   					]
   				}
   				val main = program.main
   				members += main.toMethod('doRun', null) [
   					parameters += main.toParameter('it', main.newTypeRef(IRobot))
   					body = main.body
   				]
   				members += main.toMethod('run', null) [
   					parameters += main.toParameter('it', main.newTypeRef(IRobot))
   					body = '''
   						«IF main.isLoop»
   							do {
   								doRun(it);
   								waitForUpdate(1000);
   							} while(true)
   						«ELSE»
   							doRun(it);
   						«ENDIF»
   					'''
   				]
   				for (sub : program.subs) {
   					members += sub.toMethod(sub.name, sub.body.inferredType) [
   						parameters += sub.parameters.map [ toParameter(name, parameterType) ]
   						body = sub.body
   					]
   				}
   			]
   	}
}

