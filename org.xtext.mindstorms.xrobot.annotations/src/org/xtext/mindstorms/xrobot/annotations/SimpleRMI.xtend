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
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(ElementType.TYPE)
@Active(SimpleRemoteProcessor)
@Retention(RetentionPolicy.SOURCE)
annotation SimpleRMI {
}

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation SimpleRMINoAPI {
}

class SimpleRemoteProcessor extends AbstractClassProcessor {
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerInterface(annotatedClass.clientInterfaceName)
		context.registerClass(annotatedClass.serverImplName)
		context.registerClass(annotatedClass.clientExecutorName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val clientInterface = annotatedClass.clientInterfaceName.findInterface
		annotatedClass.implementedInterfaces = annotatedClass.implementedInterfaces + #[clientInterface.newTypeReference()]

		val serverImpl = annotatedClass.serverImplName.findClass
		serverImpl.extendedClass = 'org.xtext.mindstorms.xrobot.server.AbstractRemoteProxy'.newTypeReference
		serverImpl.addConstructor [
			primarySourceElement = annotatedClass
			addParameter('socket', Socket.newTypeReference())
			body = '''
				super(socket);
			'''
		]
		
		val noApiAnnotation = SimpleRMINoAPI.findTypeGlobally
		val sourceMethods = annotatedClass
					.declaredMethods
					.filter[!static && visibility == Visibility.PUBLIC]
		sourceMethods.forEach[sourceMethod, i |
			if(!sourceMethod.annotations.exists[annotationTypeDeclaration == noApiAnnotation]) {
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
						output.writeInt(«i»);
						«FOR p: sourceMethod.parameters»
							output.write«p.type.simpleName.toFirstUpper»(«p.simpleName»);
						«ENDFOR»
						output.flush();
						«IF !sourceMethod.returnType.isVoid»return «ENDIF»«sourceMethod.returnType.readCall»;
					} catch («IOException.newTypeReference» exc) {
						throw new RuntimeException(exc);
					}
				'''
			])
		]
			
		val clientExecutor = context.findClass(annotatedClass.clientExecutorName)
		clientExecutor.extendedClass = 'org.xtext.mindstorms.xrobot.client.AbstractExecutor'.newTypeReference		
		clientExecutor.addConstructor[
			primarySourceElement = annotatedClass
			addParameter('input', 'java.io.DataInputStream'.newTypeReference)
			addParameter('output', 'java.io.DataOutputStream'.newTypeReference)
			addParameter('client', annotatedClass.newTypeReference)
			body = '''
				super(input, output);
				this.client = client;
			'''
		]
		clientExecutor.addField('client', [
			primarySourceElement = annotatedClass
			type = annotatedClass.newTypeReference 
		])
		clientExecutor.addMethod('executeNext', [
			primarySourceElement = annotatedClass
			returnType = Boolean.TYPE.newTypeReference
			body = '''
				try {
					switch (input.readInt()) {
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
							«sourceMethod.returnType.writeCalls»
							output.flush();
							break;
						}
						«ENDFOR»
						default:
							return super.executeNext();
					}
					return true;
				} catch(«IOException.newTypeReference» exc) {
					throw new RuntimeException(exc);
				}
			'''
		])
	}
	
	private def getClientInterfaceName(ClassDeclaration it) {
		packageName + '.api.I' + simpleName 
	}
	
	private def getServerImplName(ClassDeclaration it) {
		packageName + '.server.Remote' + simpleName + 'Proxy'
	}
	
	private def getClientExecutorName(ClassDeclaration it) {
		packageName + '.client.' + simpleName + 'Executor'
	}
	
	private def getPackageName(ClassDeclaration c) {
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
						input.readDouble(), input.readDouble(), input.readDouble())
				'''
			default: '''
					input.read«toFirstUpper»()
				'''
		}.toString.trim
	}
	
	private def getWriteCalls(TypeReference returnType) {
		switch it: returnType.type.simpleName {
			case 'void': '''
					output.writeBoolean(true);
				'''
			case 'String': '''
					output.writeUTF(result);
				'''
			case 'SensorSample': '''
					output.writeLong(result.getTimestamp());
					output.writeDouble(result.getEnemyAngle());
					output.writeDouble(result.getEnemyDistance());
					output.writeDouble(result.getDistance());
					output.writeDouble(result.getGroundColor());
					output.writeDouble(result.getContact());
				'''
			default: '''
					output.write«toFirstUpper»(result);
				'''
		}
	}
	
}