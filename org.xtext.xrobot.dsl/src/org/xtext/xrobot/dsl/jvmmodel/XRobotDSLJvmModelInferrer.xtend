package org.xtext.xrobot.dsl.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.xtext.xrobot.api.IRobot
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
   			.accept(program.toClass("org.xtext.xrobot.dsl." +program.eResource.URI.trimFileExtension.lastSegment,
   			[
   				superTypes += typeRef(IRobot)
   				for (variable : program.variables) {
   					var variableType = variable.type ?: variable?.initializer?.inferredType ?: Object.typeRef  
   					members += variable.toField(variable.name, variableType) [
   						initializer = variable.initializer
   					]
   				}
   				for(mode: program.modes) {
	   				members += mode.toMethod('_' + mode.name + '_action', void.typeRef) [
	   					body = mode.action
	   				]
	   				if(mode.condition != null) {
		   				members += mode.toMethod('_' + mode.name + '_condition', boolean.typeRef) [
		   					body = mode.condition
		   				]
	   				}
	   				if(mode.whenLeft != null) {
			   			members += mode.toMethod('_' + mode.name + '_whenLeft', void.typeRef) [
		   					body = mode.whenLeft
	   					]
	   				} 
   				}
   				for (function : program.functions) {
   					if (function.body != null)
	   					members += function.toMethod(function.name, function.returnType ?: function.body.inferredType) [
	   						parameters += function.parameters.map [ toParameter(name, parameterType) ]
	   						body = function.body
	   					]
   				}
   			]
   		))
   	}
}

