package org.xtext.xrobot.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.nio.channels.SocketChannel
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(SimpleRemoteProcessor)
@Retention(RetentionPolicy.SOURCE)
annotation SimpleRMI {
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation NoAPI {
}

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.SOURCE)
annotation SubComponent {
}

class SimpleRemoteProcessor extends AbstractClassProcessor {
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerInterface(annotatedClass.clientInterfaceName)
		context.registerClass(annotatedClass.serverImplName)
		context.registerClass(annotatedClass.clientExecutorName)
		context.registerClass(annotatedClass.clientStateName)
		context.registerClass(annotatedClass.serverStateName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val clientInterface = annotatedClass.clientInterfaceName.findInterface
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[clientInterface.newTypeReference]
		val clientStateClass = findClass(annotatedClass.clientStateName)
		val serverStateClass = findClass(annotatedClass.serverStateName)
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]

		val serverImpl = annotatedClass.serverImplName.findClass
		serverImpl.implementedInterfaces = #[clientInterface.newTypeReference]
		serverImpl.addField('state') [
			type = serverStateClass.newTypeReference
		]
		serverImpl.addField('socket') [
			type = SocketChannel.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('componentID') [
			type = int.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('input') [
			type = 'org.xtext.xrobot.net.SocketInputBuffer'.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('output') [
			type = 'org.xtext.xrobot.net.SocketOutputBuffer'.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addConstructor [
			primarySourceElement = annotatedClass
			addParameter('socket', SocketChannel.newTypeReference)
			addParameter('componentID', int.newTypeReference)
			body = '''
				this.socket = socket;
				this.componentID = componentID;
				this.input = new SocketInputBuffer(socket); 
				this.output = new SocketOutputBuffer(socket);
			'''
		]
		serverImpl.addMethod('setState') [
			addParameter('state', serverStateClass.newTypeReference)
			body = '''
				this.state = state;
				«FOR subComponent: subComponentFields» 
					«subComponent.simpleName».setState(state.get«subComponent.simpleName.toFirstUpper()»State());
				«ENDFOR»
			'''
		]
		serverImpl.addMethod('getState') [
			returnType = serverStateClass.newTypeReference
			body = '''
				return state;
			'''
		]
		val noApiAnnotation = NoAPI.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		sourceMethods.forEach[sourceMethod, i |
			if(sourceMethod.findAnnotation(noApiAnnotation) == null) {
				clientInterface.addMethod(sourceMethod.simpleName, [
					ciMethod |
					ciMethod.primarySourceElement = sourceMethod
					sourceMethod.parameters.forEach[
						ciMethod.addParameter(it.simpleName, it.type)
					]
					ciMethod.returnType = sourceMethod.returnType
				])
			}
			if(!sourceMethod.returnType.isVoid) {
				clientStateClass.addField(sourceMethod.fieldName) [
					type = sourceMethod.returnType
				]
				serverStateClass.addField(sourceMethod.fieldName) [
					type = sourceMethod.returnType
				]
				serverStateClass.addMethod('get' + sourceMethod.fieldName.toFirstUpper) [
					returnType = sourceMethod.returnType
					body = '''
						return «sourceMethod.fieldName»;
					'''
				]
			}
			serverImpl.addMethod(sourceMethod.simpleName, [
				serverMethod |
				serverMethod.primarySourceElement = sourceMethod 
				sourceMethod.parameters.forEach[
					serverMethod.addParameter(it.simpleName, it.type)
				]
				serverMethod.returnType = sourceMethod.returnType
				if (!serverMethod.returnType.isVoid)
					serverMethod.body = '''
						return state.get«serverMethod.fieldName.toFirstUpper»();
					'''
				else
					serverMethod.body = '''
						output.writeInt(componentID);
						output.writeInt(«i»);
						«FOR p: sourceMethod.parameters»
							«getWriteCalls(p.type, p.simpleName)»
						«ENDFOR»
						output.send();
					'''
			])
		]
		var componentID = 1
		for(subComponent: subComponentFields) {
			val finalID = componentID++
			annotatedClass.addMethod('get' + subComponent.simpleName.toFirstUpper, [
				primarySourceElement = subComponent
				returnType = newTypeReference(subComponent.type.type)
				body = '''
					return «subComponent.simpleName»;
				'''
			])
			clientInterface.addMethod('get' + subComponent.simpleName.toFirstUpper, [
				primarySourceElement = subComponent
				returnType = newTypeReference(subComponent.type.type.clientInterfaceName)
			])
			serverImpl.addField(subComponent.simpleName, [
				primarySourceElement = subComponent
				type = newTypeReference(subComponent.type.type.serverImplName)
				initializer = '''
					new «type»(socket, «finalID»)
				'''
			])
			serverImpl.addMethod('get' + subComponent.simpleName.toFirstUpper, [
				primarySourceElement = subComponent
				returnType = newTypeReference(subComponent.type.type.serverImplName)
				body = '''
					return «subComponent.simpleName»;
				'''
			])
		}
		val clientExecutor = context.findClass(annotatedClass.clientExecutorName)
		clientExecutor.extendedClass = 'org.xtext.xrobot.client.AbstractExecutor'.newTypeReference		
		clientExecutor.addField('client', [
			primarySourceElement = annotatedClass
			type = annotatedClass.newTypeReference 
		])
		for(subComponent: subComponentFields) {
			clientExecutor.addField(subComponent.simpleName, [
				primarySourceElement = subComponent
				type = newTypeReference(subComponent.type.type.clientExecutorName)
			])
			clientStateClass.addField(subComponent.simpleName + 'State') [
				type = subComponent.type.type.clientStateName.newTypeReference
				initializer = '''
					new «subComponent.type.type.clientStateName.newTypeReference»()
				'''
			]
			serverStateClass.addField(subComponent.simpleName + 'State') [
				type = subComponent.type.type.serverStateName.newTypeReference
				initializer = '''
					new «subComponent.type.type.serverStateName.newTypeReference»()
				'''
			]
			serverStateClass.addMethod('get' + subComponent.simpleName.toFirstUpper + 'State') [
				returnType = subComponent.type.type.serverStateName.newTypeReference
				body = '''
					return «subComponent.simpleName»State;
				'''
			]
		}
		clientExecutor.addConstructor[
			primarySourceElement = annotatedClass
			addParameter('input', 'org.xtext.xrobot.net.SocketInputBuffer'.newTypeReference)
			addParameter('client', annotatedClass.newTypeReference)
			body = '''
				super(input);
				this.client = client;
				«FOR subComponent: subComponentFields»
					«subComponent.simpleName» = new «newTypeReference(subComponent.type.type.clientExecutorName)»(input, client.get«subComponent.simpleName.toFirstUpper»());
				«ENDFOR»
			'''
		]
		clientExecutor.addMethod('getSubComponent', [
			primarySourceElement = annotatedClass
			returnType = 'org.xtext.xrobot.client.AbstractExecutor'.findTypeGlobally.newTypeReference
			addParameter('componentID', int.newTypeReference())
			body = '''
				switch(componentID) {
					case 0: 
						return this;
					«var id = 1»
					«FOR subComponent: subComponentFields»
						case «id++»: 
							return «subComponent.simpleName»;
					«ENDFOR»
					default:
						System.err.println("No such component " + componentID);
						return null;
				}
			''' 
		])		
		clientExecutor.addMethod('execute') [
			primarySourceElement = annotatedClass
			addParameter("messageType", int.newTypeReference)
			returnType = boolean.newTypeReference
			visibility = Visibility.PROTECTED
			body = '''
				switch (messageType) {
					«var i = 0»
					«FOR sourceMethod: sourceMethods»
						«IF sourceMethod.returnType.isVoid»
							case «i»: {
								client.«sourceMethod.simpleName»(«
								FOR p: sourceMethod.parameters SEPARATOR ', '
									»«p.type.readCall»«
								ENDFOR»);
								break;
							}
						«ENDIF»
						«{i++; ''}»
					«ENDFOR»
					default:
						return super.execute(messageType);
				}
				return true;
			'''
		]
		clientStateClass.addField('sampleTime') [
			type = long.newTypeReference()
		]
		clientStateClass.addMethod('sample') [
			addParameter('robot', annotatedClass.newTypeReference)
			body = '''
				sampleTime = System.currentTimeMillis();
				«FOR sourceMethod: sourceMethods.filter[!returnType.void]»
					«sourceMethod.fieldName» = robot.«sourceMethod.simpleName»();
				«ENDFOR»
				«FOR subComponent: subComponentFields»
					«subComponent.simpleName»State.sample(robot.get«subComponent.simpleName.toFirstUpper»());
				«ENDFOR»
			'''
		]
		clientStateClass.addMethod('write') [
			addParameter('output', 'org.xtext.xrobot.net.SocketOutputBuffer'.newTypeReference)
			body = '''
				output.writeLong(sampleTime);
				«FOR sourceMethod: sourceMethods.filter[!returnType.void]»
					«getWriteCalls(sourceMethod.returnType, sourceMethod.fieldName)»
				«ENDFOR»
				«FOR subComponent: subComponentFields»
					«subComponent.simpleName»State.write(output);
				«ENDFOR»
			'''
		]
		serverStateClass.addField('sampleTime') [
			type = long.newTypeReference()
		]
		serverStateClass.addMethod('getSampleTime') [
			returnType = long.newTypeReference()
			body = '''
				return sampleTime;
			'''
		]
		serverStateClass.addMethod('read') [
			addParameter('input', 'org.xtext.xrobot.net.SocketInputBuffer'.newTypeReference)
			body = '''
				sampleTime = input.readLong();
				«FOR sourceMethod: sourceMethods.filter[!returnType.void]»
					«sourceMethod.fieldName» = «getReadCall(sourceMethod.returnType)»;
				«ENDFOR»
				«FOR subComponent: subComponentFields»
					«subComponent.simpleName»State.read(input);
				«ENDFOR»
				
			'''
		]
	}
	
	private def getFieldName(MethodDeclaration accessor) {
		val accessorName = accessor.simpleName
		return (if(accessorName.startsWith('get'))
			accessorName.substring(3)
		else if(accessorName.startsWith('is')) 
			accessorName.substring(2)
		else 
			accessorName).toFirstLower
			
	}
	
	private def getClientInterfaceName(Type it) {
		packageName + '.api.I' + simpleName 
	}
	
	private def getServerImplName(Type it) {
		packageName + '.server.Remote' + simpleName + 'Proxy'
	}
	
	private def getClientExecutorName(Type it) {
		packageName + '.client.' + simpleName + 'Executor'
	}
	
	private def getClientStateName(Type it) {
		packageName + '.client.' + simpleName + 'ClientState'
	}
	
	private def getServerStateName(Type it) {
		packageName + '.server.' + simpleName + 'ServerState'
	}
	
	private def getPackageName(Type c) {
		val qName = c.qualifiedName
		val packageName = qName.substring(0, qName.lastIndexOf('.'))
		packageName
	}
		
	private def getTypeName(TypeReference typeReference) {
		if(typeReference.isPrimitive)
			typeReference.type.simpleName
		else
			typeReference.type.qualifiedName
	}
	
	private def getReadCall(TypeReference returnType) {
		switch it: returnType.type.simpleName {
			case 'void': '''
					input.readBoolean()
				'''
			case 'String': '''
					input.readString()
				'''
			case 'OpponentPosition': '''
					new «returnType.typeName»(input.readDouble(), input.readDouble())
				'''
			default: '''
					input.read«toFirstUpper»()
				'''
		}.toString.trim
	}
	
	private def getWriteCalls(TypeReference returnType, String variableName) {
		switch it: returnType.type.simpleName {
			case 'void': '''
					output.writeBoolean(true);
				'''
			case 'String': '''
					output.writeString(«variableName»);
				'''
			case 'OpponentPosition': '''
					output.writeDouble(«variableName».getRawAngular());
					output.writeDouble(«variableName».getRawDistance());
				'''
			default: '''
					output.write«toFirstUpper»(«variableName»);
				'''
		}
	}
	
}