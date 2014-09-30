package org.xtext.xrobot.annotations

import java.io.IOException
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
import com.google.common.base.Predicate

@Target(ElementType.TYPE)
@Active(SimpleRemoteProcessor)
@Retention(RetentionPolicy.SOURCE)
annotation SimpleRMI {
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation NoAPI {
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation Calculated {
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation Zombie {
}

/**
 * This annotation marks a blocking command. Once such a command is started, no further
 * commands are executed until the blocking command has finished or is canceled. 
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation Blocking {
	String value = 'getMoving'
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
		clientInterface.extendedInterfaces = #['org.xtext.xrobot.api.IRobotGeometry'.newTypeReference]
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[clientInterface.newTypeReference]
		val clientStateClass = annotatedClass.clientStateName.findClass
		val serverStateClass = annotatedClass.serverStateName.findClass
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]

		val serverImpl = annotatedClass.serverImplName.findClass
		serverImpl.implementedInterfaces = #[clientInterface.newTypeReference, 'org.xtext.xrobot.net.INetConfig'.newTypeReference]
		serverImpl.addField('state') [
			type = serverStateClass.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('LOG') [
			type = 'org.apache.log4j.Logger'.newTypeReference
			static = true
			final = true
			initializer = '''
				«'org.apache.log4j.Logger'.newTypeReference».getLogger(«serverImpl».class)
			'''
			visibility = Visibility.PRIVATE
		]
		serverImpl.addField('socket') [
			type = SocketChannel.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('componentID') [
			type = int.newTypeReference
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('stateProvider') [
			type = 'org.xtext.xrobot.server.StateProvider'.newTypeReference(serverStateClass.newTypeReference)
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
		serverImpl.addField('nextCommandSerialNr') [
			type = int.newTypeReference
			visibility = Visibility.PROTECTED
		] 
		serverImpl.addField('cancelIndicator') [
			type = 'org.eclipse.xtext.util.CancelIndicator'.newTypeReference
			visibility = Visibility.PROTECTED
		] 
		serverImpl.addConstructor [
			primarySourceElement = annotatedClass
			addParameter('componentID', int.newTypeReference)
			addParameter('nextCommandSerialNr', int.newTypeReference)
			addParameter('socket', SocketChannel.newTypeReference)
			addParameter('stateProvider', 'org.xtext.xrobot.server.StateProvider'.newTypeReference(serverStateClass.newTypeReference))
			addParameter('cancelIndicator', 'org.eclipse.xtext.util.CancelIndicator'.newTypeReference)
			body = '''
				this.componentID = componentID;
				this.nextCommandSerialNr = nextCommandSerialNr;
				this.socket = socket;
				this.stateProvider = stateProvider;
				this.cancelIndicator = cancelIndicator;
				this.input = new SocketInputBuffer(socket); 
				this.output = new SocketOutputBuffer(socket);
				«var id = 1»
				«FOR subComponent: subComponentFields»
					this.«subComponent.simpleName» = new «subComponent.type.type.serverImplName»(«id++», nextCommandSerialNr, socket, new «'org.xtext.xrobot.server.StateProvider'.newTypeReference(subComponent.type.type.serverStateName.newTypeReference())»() {
						public «subComponent.type.type.serverStateName.newTypeReference()» getState() {
							return state.get«subComponent.simpleName.toFirstUpper»State();
						}
					}, cancelIndicator);
				«ENDFOR»
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
		serverImpl.addMethod('checkCanceled') [
			visibility = Visibility.PROTECTED
			body = '''
				if(cancelIndicator.isCanceled()) 
					throw new CanceledException();
			'''
		]
		serverImpl.addMethod('waitFinished') [
			visibility = Visibility.PROTECTED
			addParameter('commandSerialNr', int.newTypeReference())
			addParameter('isMoving', Predicate.newTypeReference(serverStateClass.newTypeReference))
			body = '''
				«serverStateClass.newTypeReference» newState = stateProvider.getState();
				while(newState.getLastExecutedCommandSerialNr() < commandSerialNr
					|| (newState.getLastExecutedCommandSerialNr() == commandSerialNr 
					&& isMoving.apply(newState))) {
					checkCanceled();
					Thread.yield();
					newState = stateProvider.getState();
				}
			'''
		]
		val noApiAnnotation = NoAPI.findTypeGlobally
		val zombieAnnotation = Zombie.findTypeGlobally
		val calculatedAnnotation = Calculated.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		sourceMethods.forEach[sourceMethod, i |
			if(sourceMethod.findAnnotation(noApiAnnotation) == null) {
				clientInterface.addMethod(sourceMethod.simpleName, [
					ciMethod |
					ciMethod.docComment = sourceMethod.docComment
					ciMethod.primarySourceElement = sourceMethod
					sourceMethod.parameters.forEach[
						ciMethod.addParameter(it.simpleName, it.type)
					]
					ciMethod.returnType = sourceMethod.returnType
				])
			}
			if(!sourceMethod.returnType.isVoid && sourceMethod.findAnnotation(calculatedAnnotation) == null) {
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
				if (sourceMethod.findAnnotation(calculatedAnnotation) != null) 
					serverMethod.body = '''
						// subclasses should override
						return«IF !sourceMethod.returnType.isVoid» null«ENDIF»;
					'''
				else if (!serverMethod.returnType.isVoid)
					serverMethod.body = '''
						«IF sourceMethod.findAnnotation(zombieAnnotation) == null»
							checkCanceled();
						«ENDIF»
						LOG.debug("«sourceMethod.simpleName»");
						return state.get«serverMethod.fieldName.toFirstUpper»();
					'''
				else 
					serverMethod.body = '''
						«IF sourceMethod.findAnnotation(zombieAnnotation) == null»
							checkCanceled();
						«ENDIF»
						output.writeInt(componentID);
						output.writeInt(«i»);
						«FOR p: sourceMethod.parameters»
							«getWriteCalls(p.type, p.simpleName)»
						«ENDFOR»
						int commandSerialNr = nextCommandSerialNr++;
						output.writeInt(commandSerialNr);
						output.send();
						LOG.debug("«sourceMethod.simpleName» " + commandSerialNr);
						«IF sourceMethod.getBlockingValue(context) != null»
							waitFinished(commandSerialNr, new Predicate<«serverStateClass»>() {
								@Override 
								public boolean apply(«serverStateClass» state) {
									return state.«sourceMethod.getBlockingValue(context)»();
								}
							});
						«ENDIF»
					'''
			])
		]
		for(subComponent: subComponentFields) {
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
		clientExecutor.addField('LOG', [
			primarySourceElement = annotatedClass
			type = 'org.apache.log4j.Logger'.newTypeReference
			static = true
			final = true
			initializer = '''
				«'org.apache.log4j.Logger'.newTypeReference».getLogger(«clientExecutor».class)
			'''
			visibility = Visibility.PRIVATE 
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
						LOG.error("No such component " + componentID);
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
								LOG.debug("«sourceMethod.simpleName» ");
								client.«sourceMethod.simpleName»(«
								FOR p: sourceMethod.parameters SEPARATOR ', '
									»«p.type.getReadCalls(null)»«
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
		clientExecutor.addMethod('dispatchAndExecute') [
			returnType = boolean.newTypeReference
			exceptions = IOException.newTypeReference
			body = '''
				boolean result = super.dispatchAndExecute();
				client.setLastExecutedCommandSerialNr(input.readInt());
				LOG.debug("commandID= " + client.getLastExecutedCommandSerialNr());
				return result;
			'''
		]
		clientStateClass.addField('sampleTime') [
			type = long.newTypeReference()
		]
		clientStateClass.addField('lastExecutedCommandSerialNr') [
			type = int.newTypeReference()
		]
		clientStateClass.addMethod('sample') [
			addParameter('robot', annotatedClass.newTypeReference)
			body = '''
				sampleTime = System.currentTimeMillis();
				lastExecutedCommandSerialNr = robot.getLastExecutedCommandSerialNr(); 
				«FOR sourceMethod: sourceMethods.filter[!returnType.void && findAnnotation(calculatedAnnotation) == null]»
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
				output.writeInt(lastExecutedCommandSerialNr);
				«FOR sourceMethod: sourceMethods.filter[!returnType.void && findAnnotation(calculatedAnnotation) == null]»
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
		serverStateClass.addField('lastExecutedCommandSerialNr') [
			type = int.newTypeReference()
		]
		serverStateClass.addMethod('getSampleTime') [
			returnType = long.newTypeReference()
			body = '''
				return sampleTime;
			'''
		]
		serverStateClass.addMethod('getLastExecutedCommandSerialNr') [
			returnType = int.newTypeReference()
			body = '''
				return lastExecutedCommandSerialNr;
			'''
		]
		serverStateClass.addMethod('read') [
			addParameter('input', 'org.xtext.xrobot.net.SocketInputBuffer'.newTypeReference)
			body = '''
				sampleTime = input.readLong();
				lastExecutedCommandSerialNr = input.readInt();
				«FOR sourceMethod: sourceMethods.filter[!returnType.void && findAnnotation(calculatedAnnotation) == null]»
					«getReadCalls(sourceMethod.returnType, sourceMethod.fieldName)»;
				«ENDFOR»
				«FOR subComponent: subComponentFields»
					«subComponent.simpleName»State.read(input);
				«ENDFOR»
				
			'''
		]
		annotatedClass.addField('lastExecutedCommandSerialNr') [
			type = int.newTypeReference()
		]
		annotatedClass.addMethod('setLastExecutedCommandSerialNr') [
			addParameter('lastExecutedCommandSerialNr', int.newTypeReference)
			body = '''
				this.lastExecutedCommandSerialNr = lastExecutedCommandSerialNr;
			'''
		]
		annotatedClass.addMethod('getLastExecutedCommandSerialNr') [
			returnType = int.newTypeReference
			body = '''
				return lastExecutedCommandSerialNr;
			'''
		]
		
	}
	
	private def String getBlockingValue(MethodDeclaration method, extension TransformationContext context) {
		method.findAnnotation(Blocking.findTypeGlobally)?.getStringValue('value')
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
		
	private def getReadCalls(TypeReference returnType, String variableName) {
		val assignment = if(variableName != null) variableName + ' = ' else ''
		switch it: returnType.type.simpleName {
			case 'void': '''
					«assignment»input.readBoolean()
				'''
			case 'String': '''
					«assignment»input.readString()
				'''
			case 'OpponentPosition': '''
					int channel = input.readInt();
					int dataLength = input.readInt();
					float[] rawData = new float[dataLength];
					for(int i=0; i<dataLength; ++i) {
						rawData[i] = input.readFloat();
					}
					«assignment»new «returnType»(rawData, channel)
				'''
			default: '''
					«assignment»input.read«toFirstUpper»()
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
					output.writeInt(«variableName».getChannel());
					output.writeInt(«variableName».getRawData().length);
					for(int i=0; i<«variableName».getRawData().length; ++i) 
						output.writeFloat(«variableName».getRawData()[i]);
				'''
			default: '''
					output.write«toFirstUpper»(«variableName»);
				'''
		}
	}
	
}