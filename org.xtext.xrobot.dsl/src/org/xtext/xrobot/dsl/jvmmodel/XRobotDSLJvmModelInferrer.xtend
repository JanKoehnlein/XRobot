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
   				for(field: program.fields) {
   					var fieldType = field.type ?: field?.initializer?.inferredType ?: Object.typeRef  
   					members += field.toField(field.name, fieldType) [
   						initializer = field.initializer
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
	   				if(mode.whenCanceled != null) {
			   			members += mode.toMethod('_' + mode.name + '_whenCanceled', void.typeRef) [
		   					body = mode.whenCanceled
	   					]
	   				} 
   				}
   				for (sub : program.subs) {
   					if (sub.body != null)
	   					members += sub.toMethod(sub.name, sub.returnType ?: sub.body.inferredType) [
	   						parameters += sub.parameters.map [ toParameter(name, parameterType) ]
	   						body = sub.body
	   					]
   				}
   			]
   		))
   	}
}

