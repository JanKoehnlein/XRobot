/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.dsl.xRobotDSL.Program

import static org.eclipse.xtext.common.types.JvmVisibility.*

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
   						visibility = PRIVATE
   					]
   				}
   				for(mode: program.modes) {
	   				members += mode.toMethod('_' + mode.name + '_action', void.typeRef) [
	   					body = mode.action
	   				]
	   				if (mode.condition != null) {
		   				members += mode.toMethod('_' + mode.name + '_condition', boolean.typeRef) [
		   					body = mode.condition
		   				]
	   				}
	   				if (mode.whenLeft != null) {
			   			members += mode.toMethod('_' + mode.name + '_whenLeft', void.typeRef) [
		   					body = mode.whenLeft
	   					]
	   				} 
   				}
   				for (function : program.functions) {
   					if (function.body != null) {
	   					members += function.toMethod(function.name, function.returnType ?: function.body.inferredType) [
	   						parameters += function.parameters.map [ toParameter(name, parameterType) ]
	   						body = function.body
   							visibility = PRIVATE
	   					]
   					}
   				}
   			]
   		))
   	}
}

