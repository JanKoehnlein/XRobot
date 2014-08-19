package org.xtext.mindstorms.xrobot.annotations

import java.io.IOException
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.net.Socket
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
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
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val clientInterface = annotatedClass.clientInterfaceName.findInterface
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[clientInterface.newTypeReference]

		val serverImpl = annotatedClass.serverImplName.findClass
		serverImpl.extendedClass = 'org.xtext.mindstorms.xrobot.server.AbstractRemoteProxy'.newTypeReference
		serverImpl.implementedInterfaces = #[clientInterface.newTypeReference]
		serverImpl.addConstructor [
			primarySourceElement = annotatedClass
			addParameter('socket', Socket.newTypeReference)
			addParameter('componentID', int.newTypeReference)
			body = '''
				super(socket, componentID);
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
			serverImpl.addMethod(sourceMethod.simpleName, [
				serverMethod |
				serverMethod.primarySourceElement = sourceMethod 
				sourceMethod.parameters.forEach[
					serverMethod.addParameter(it.simpleName, it.type)
				]
				serverMethod.returnType = sourceMethod.returnType
				serverMethod.body = '''
					try {
						output.writeInt(componentID);
						output.writeInt(«i»);
						«FOR p: sourceMethod.parameters»
							«getWriteCalls(p.type, p.simpleName)»
						«ENDFOR»
						output.flush();
						«IF !sourceMethod.returnType.isVoid»return «ENDIF»«sourceMethod.returnType.readCall»;
					} catch («IOException.newTypeReference» exc) {
						throw new RuntimeException(exc);
					}
				'''
			])
		]
		var componentID = 1
		val subCompontentAnnotation = SubComponent.findTypeGlobally
		val subComponentFields = annotatedClass.declaredFields.filter[findAnnotation(subCompontentAnnotation) != null]
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
		clientExecutor.extendedClass = 'org.xtext.mindstorms.xrobot.client.AbstractExecutor'.newTypeReference		
		clientExecutor.addField('client', [
			primarySourceElement = annotatedClass
			type = annotatedClass.newTypeReference 
		])
		for(subComponent: subComponentFields) {
			clientExecutor.addField(subComponent.simpleName, [
				primarySourceElement = subComponent
				type = newTypeReference(subComponent.type.type.clientExecutorName)
			])
		}
		clientExecutor.addConstructor[
			primarySourceElement = annotatedClass
			addParameter('input', 'java.io.DataInputStream'.newTypeReference)
			addParameter('output', 'java.io.DataOutputStream'.newTypeReference)
			addParameter('client', annotatedClass.newTypeReference)
			body = '''
				super(input, output);
				this.client = client;
				«FOR subComponent: subComponentFields»
					«subComponent.simpleName» = new «newTypeReference(subComponent.type.type.clientExecutorName)»(input, output, client.get«subComponent.simpleName.toFirstUpper»());
				«ENDFOR»
			'''
		]
		clientExecutor.addMethod('getSubComponent', [
			primarySourceElement = annotatedClass
			returnType = 'org.xtext.mindstorms.xrobot.client.AbstractExecutor'.findTypeGlobally.newTypeReference
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
		clientExecutor.addMethod('dispatchAndExecute', [
			primarySourceElement = annotatedClass
			returnType = boolean.newTypeReference
			exceptions = #[IOException.newTypeReference()]
			body = '''
				int componentID = input.readInt();
				AbstractExecutor subComponent = getSubComponent(componentID);
				if(subComponent != null)
					return subComponent.executeNext();
				else
					return true;
			'''	
		])
		clientExecutor.addMethod('execute', [
			primarySourceElement = annotatedClass
			addParameter("messageType", int.newTypeReference)
			returnType = boolean.newTypeReference
			visibility = Visibility.PROTECTED
			body = '''
				try {
					switch (messageType) {
						«var i = 0»
						«FOR sourceMethod: sourceMethods»
						case «i++»: {
							«IF !sourceMethod.returnType.isVoid
								»«sourceMethod.returnType.typeName» result = «
							 ENDIF
							»client.«sourceMethod.simpleName»(«
								FOR p: sourceMethod.parameters SEPARATOR ', '
								»«p.type.readCall»«
								ENDFOR»);
							«sourceMethod.returnType.getWriteCalls('result')»
							output.flush();
							break;
						}
						«ENDFOR»
						default:
							return super.execute(messageType);
					}
					return true;
				} catch(«IOException.newTypeReference» exc) {
					throw new RuntimeException(exc);
				}
			'''
		])
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
					input.readUTF()
				'''
			case 'SensorSample': '''
					new «returnType.typeName»(input.readLong(), 
						input.readDouble(), input.readDouble(), 
						input.readDouble(), input.readDouble()/*, input.readDouble()*/)
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
					output.writeUTF(«variableName»);
				'''
			case 'SensorSample': '''
					output.writeLong(«variableName».getTimestamp());
					output.writeDouble(«variableName».getEnemyAngle());
					output.writeDouble(«variableName».getEnemyDistance());
					output.writeDouble(«variableName».getDistance());
					output.writeDouble(«variableName».getGroundColor());
					//output.writeDouble(«variableName».getContact());
				'''
			default: '''
					output.write«toFirstUpper»(«variableName»);
				'''
		}
	}
	
}