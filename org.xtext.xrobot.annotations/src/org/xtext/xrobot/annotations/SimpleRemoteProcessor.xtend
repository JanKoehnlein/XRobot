package org.xtext.xrobot.annotations

import com.google.common.base.Predicate
import java.io.IOException
import java.net.SocketException
import java.nio.channels.SocketChannel
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableInterfaceDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.util.Wrapper

/**
 * A processor for RMI code generation.
 */
class SimpleRemoteProcessor extends AbstractClassProcessor {
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerInterface(annotatedClass.clientInterfaceName)
		context.registerClass(annotatedClass.serverImplName)
		context.registerClass(annotatedClass.clientExecutorName)
		context.registerClass(annotatedClass.clientStateName)
		context.registerClass(annotatedClass.serverStateName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val clientInterface = generateClientInterface(annotatedClass, context)
		generateClientState(annotatedClass, context)
		generateClientExecutor(annotatedClass, context)
		val serverStateClass = generateServerState(annotatedClass, context)
		generateServerImpl(annotatedClass, clientInterface, serverStateClass, context)
		
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[clientInterface.newTypeReference]
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
		for (subComponent: subComponentFields) {
			annotatedClass.addMethod('get' + subComponent.simpleName.toFirstUpper, [
				primarySourceElement = subComponent
				returnType = newTypeReference(subComponent.type.type)
				body = '''
					return «subComponent.simpleName»;
				'''
			])
		}
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
	
	/**
	 * Generate the interface representing the API.
	 */
	private def generateClientInterface(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val clientInterface = annotatedClass.clientInterfaceName.findInterface
		clientInterface.docComment = annotatedClass.docComment
		val noApiAnnotation = NoAPI.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		for (sourceMethod : sourceMethods) {
			if (sourceMethod.findAnnotation(noApiAnnotation) == null) {
				clientInterface.addMethod(sourceMethod.simpleName, [ ciMethod |
					ciMethod.docComment = sourceMethod.docComment
					ciMethod.primarySourceElement = sourceMethod
					sourceMethod.parameters.forEach[
						ciMethod.addParameter(it.simpleName, it.type)
					]
					ciMethod.returnType = sourceMethod.returnType
				])
			}
		}
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
		for (subComponent: subComponentFields) {
			clientInterface.addMethod('get' + subComponent.simpleName.toFirstUpper, [
				primarySourceElement = subComponent
				returnType = newTypeReference(subComponent.type.type.clientInterfaceName)
			])
		}
		annotatedClass.declaredFields
			.filter [visibility == Visibility.PUBLIC && static && final]
			.forEach [ sourceField |
				clientInterface.addField(sourceField.simpleName, [
					static = true
					visibility = Visibility.PUBLIC
					final = true
					type = sourceField.type
					docComment = sourceField.docComment
					initializer = sourceField.initializer  
				])
				sourceField.remove
			]
		return clientInterface
	}

	/**
	 * Generate the data class representing the sampled state on the client side.
	 */	
	private def generateClientState(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val clientStateClass = annotatedClass.clientStateName.findClass
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
		val calculatedAnnotation = Calculated.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		for (sourceMethod : sourceMethods) {
			if (!sourceMethod.returnType.isVoid && sourceMethod.findAnnotation(calculatedAnnotation) == null) {
				clientStateClass.addField(sourceMethod.fieldName) [
					type = sourceMethod.returnType
					visibility = Visibility.DEFAULT
				]
			}
		}
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
		return clientStateClass
	}
	
	/**
	 * Generate the executor class that processes commands received from the server.
	 */
	private def generateClientExecutor(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
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
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
		for (subComponent: subComponentFields) {
			clientExecutor.addField(subComponent.simpleName, [
				primarySourceElement = subComponent
				type = newTypeReference(subComponent.type.type.clientExecutorName)
			])
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
		val calculatedAnnotation = Calculated.findTypeGlobally
		val zombieAnnotation = Zombie.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		clientExecutor.addMethod('execute') [
			primarySourceElement = annotatedClass
			addParameter("messageType", int.newTypeReference)
			addParameter("isAlive", boolean.newTypeReference)
			returnType = boolean.newTypeReference
			visibility = Visibility.PROTECTED
			body = '''
				switch (messageType) {
					«var i = 0»
					«FOR sourceMethod: sourceMethods»
						«IF sourceMethod.returnType.isVoid && sourceMethod.findAnnotation(calculatedAnnotation) == null»
							case «i»: {
								LOG.debug("«sourceMethod.simpleName» ");
								«IF sourceMethod.findAnnotation(zombieAnnotation) == null»
									if (isAlive) {
										client.«sourceMethod.simpleName»(«
										FOR p: sourceMethod.parameters SEPARATOR ', '
											»«p.type.getReadCalls(null)»«
										ENDFOR»);
									}«IF !sourceMethod.parameters.empty» else {
										// Discard message content
										«FOR p: sourceMethod.parameters»
											«p.type.getReadCalls(null)»;
										«ENDFOR»
									}«ENDIF»
								«ELSE»
									client.«sourceMethod.simpleName»(«
									FOR p: sourceMethod.parameters SEPARATOR ', '
										»«p.type.getReadCalls(null)»«
									ENDFOR»);
								«ENDIF»
								break;
							}
						«ENDIF»
						«{i++; ''}»
					«ENDFOR»
					default:
						return super.execute(messageType, isAlive);
				}
				return true;
			'''
		]
		clientExecutor.addMethod('dispatchAndExecute') [
			addParameter('isAlive', boolean.newTypeReference)
			returnType = boolean.newTypeReference
			exceptions = IOException.newTypeReference
			body = '''
				boolean result = super.dispatchAndExecute(isAlive);
				client.setLastExecutedCommandSerialNr(input.readInt());
				//LOG.debug("commandID= " + client.getLastExecutedCommandSerialNr());
				return result;
			'''
		]
	}
	
	/**
	 * Generate the data class representing the state received from the client.
	 */
	private def generateServerState(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val serverStateClass = annotatedClass.serverStateName.findClass
		val calculatedAnnotation = Calculated.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		for (sourceMethod : sourceMethods) {
			if (!sourceMethod.returnType.isVoid && sourceMethod.findAnnotation(calculatedAnnotation) == null) {
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
		}
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
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
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
		return serverStateClass
	}
	
	/**
	 * Generate the server RMI implementation.
	 */
	private def generateServerImpl(MutableClassDeclaration annotatedClass, MutableInterfaceDeclaration clientInterface,
			MutableClassDeclaration serverStateClass, extension TransformationContext context) {
		val serverImpl = annotatedClass.serverImplName.findClass
		serverImpl.abstract = true
		serverImpl.implementedInterfaces = #[clientInterface.newTypeReference]
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
			final = true
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('writeLock') [
			type = Object.newTypeReference
			final = true
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('componentID') [
			type = int.newTypeReference
			final = true
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('stateProvider') [
			type = 'org.xtext.xrobot.server.StateProvider'.newTypeReference(serverStateClass.newTypeReference)
			final = true
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('input') [
			type = 'org.xtext.xrobot.net.SocketInputBuffer'.newTypeReference
			final = true
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('output') [
			type = 'org.xtext.xrobot.net.SocketOutputBuffer'.newTypeReference
			final = true
			visibility = Visibility.PROTECTED
		]
		serverImpl.addField('nextCommandSerialNr') [
			type = Wrapper.newTypeReference(Integer.newTypeReference)
			visibility = Visibility.PROTECTED
		] 
		serverImpl.addField('cancelIndicator') [
			type = 'org.eclipse.xtext.util.CancelIndicator'.newTypeReference
			final = true
			visibility = Visibility.PROTECTED
		] 
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
		serverImpl.addConstructor [
			primarySourceElement = annotatedClass
			addParameter('componentID', int.newTypeReference)
			addParameter('nextCommandSerialNr', Wrapper.newTypeReference(Integer.newTypeReference))
			addParameter('socket', SocketChannel.newTypeReference)
			addParameter('writeLock', Object.newTypeReference)
			addParameter('stateProvider', 'org.xtext.xrobot.server.StateProvider'.newTypeReference(serverStateClass.newTypeReference))
			addParameter('cancelIndicator', 'org.eclipse.xtext.util.CancelIndicator'.newTypeReference)
			body = '''
				this.componentID = componentID;
				this.nextCommandSerialNr = nextCommandSerialNr;
				this.socket = socket;
				this.writeLock = writeLock;
				this.stateProvider = stateProvider;
				this.cancelIndicator = cancelIndicator;
				this.input = new SocketInputBuffer(socket); 
				this.output = new SocketOutputBuffer(socket);
				«var id = 1»
				«FOR subComponent: subComponentFields»
					this.«subComponent.simpleName» = new «subComponent.type.type.serverImplName»(«id++», nextCommandSerialNr, socket, writeLock, new «'org.xtext.xrobot.server.StateProvider'.newTypeReference(subComponent.type.type.serverStateName.newTypeReference())»() {
						public «subComponent.type.type.serverStateName.newTypeReference()» getState() {
							return state.get«subComponent.simpleName.toFirstUpper»State();
						}
					}, cancelIndicator);
				«ENDFOR»
			'''
			visibility = Visibility.PROTECTED
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
			addParameter('commandSerialNr', int.newTypeReference)
			addParameter('isMoving', Predicate.newTypeReference(serverStateClass.newTypeReference))
			addParameter('timeout', long.newTypeReference)
			exceptions = IOException.newTypeReference
			body = '''
				try {
					long startTime = System.currentTimeMillis();
					Thread.sleep(10);
					«serverStateClass.newTypeReference» newState = stateProvider.getState();
					while(newState.getLastExecutedCommandSerialNr() < commandSerialNr
							|| (newState.getLastExecutedCommandSerialNr() == commandSerialNr 
							&& isMoving.apply(newState))) {
						if (System.currentTimeMillis() - startTime > timeout)
							throw new «SocketException.newTypeReference»("Timeout while waiting for client reply.");
						checkCanceled();
						Thread.yield();
						newState = stateProvider.getState();
					}
				} catch (InterruptedException e) {
					// Ignore exception
				}
			'''
		]
		val zombieAnnotation = Zombie.findTypeGlobally
		val calculatedAnnotation = Calculated.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		sourceMethods.forEach[sourceMethod, i |
			if (sourceMethod.findAnnotation(calculatedAnnotation) == null) {
				serverImpl.addMethod(sourceMethod.simpleName, [ serverMethod |
					serverMethod.primarySourceElement = sourceMethod 
					sourceMethod.parameters.forEach[
						serverMethod.addParameter(it.simpleName, it.type)
					]
					serverMethod.returnType = sourceMethod.returnType
					if (!serverMethod.returnType.isVoid) {
						serverMethod.body = '''
							«IF sourceMethod.findAnnotation(zombieAnnotation) == null»
								checkCanceled();
							«ENDIF»
							LOG.debug("«sourceMethod.simpleName» " + state.get«serverMethod.fieldName.toFirstUpper»());
							return state.get«serverMethod.fieldName.toFirstUpper»();
						'''
					} else {
						serverMethod.body = '''
							«IF sourceMethod.findAnnotation(zombieAnnotation) == null»
								checkCanceled();
							«ENDIF»
							try {
								int commandSerialNr = 0;
								synchronized (writeLock) {
									output.writeInt(componentID);
									output.writeInt(«i»);
									«FOR p: sourceMethod.parameters»
										«getWriteCalls(p.type, p.simpleName)»
									«ENDFOR»
									commandSerialNr = nextCommandSerialNr.get() + 1;
									nextCommandSerialNr.set(commandSerialNr);
									output.writeInt(commandSerialNr);
									output.send();
								}
								LOG.debug("«sourceMethod.simpleName» " + commandSerialNr);
								«IF sourceMethod.getBlockingValue(context) != null»
									waitFinished(commandSerialNr, new Predicate<«serverStateClass»>() {
										@Override 
										public boolean apply(«serverStateClass» state) {
											return state.«sourceMethod.getBlockingValue(context)»();
										}
									}, 60000);
								«ENDIF»
							} catch (IOException exc) {
								throw «Exceptions.newTypeReference».sneakyThrow(exc);
							}
						'''
					}
				])
			}
		]
		for (subComponent: subComponentFields) {
			serverImpl.addField(subComponent.simpleName, [
				primarySourceElement = subComponent
				type = newTypeReference(subComponent.type.type.serverImplName)
				final = true
			])
			serverImpl.addMethod('get' + subComponent.simpleName.toFirstUpper, [
				primarySourceElement = subComponent
				returnType = newTypeReference(subComponent.type.type.serverImplName)
				body = '''
					return «subComponent.simpleName»;
				'''
			])
		}
		return serverImpl
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