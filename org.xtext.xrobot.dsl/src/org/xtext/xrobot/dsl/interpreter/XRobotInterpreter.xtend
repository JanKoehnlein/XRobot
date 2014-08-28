package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import java.util.List
import org.eclipse.xtext.common.types.JvmField
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.xbase.XAbstractFeatureCall
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.EvaluationException
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations
import org.xtext.xrobot.dsl.xRobotDSL.Field
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.dsl.xRobotDSL.Sub
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.RemoteRobot

class XRobotInterpreter extends XbaseInterpreter implements INetConfig {
	
	static val IT = QualifiedName.create('it')

	IEvaluationContext baseContext

	@Inject extension IJvmModelAssociations 

	def Object execute(Program program, RemoteRobot robot, CancelIndicator cancelIndicator) {
		baseContext = createContext
		for(field: program.fields) {
			if(field.initializer != null) {
				val initialValue = field.initializer.evaluate(baseContext, cancelIndicator)
				baseContext.newValue(QualifiedName.create(field.name), initialValue.result)
			}
		}
		val evaluationContext = baseContext.fork
		evaluationContext.newValue(IT, robot)
		val main = program.main
		var Object result = null
		do {
			result = main.body.evaluate(evaluationContext, cancelIndicator).result
			robot.waitForUpdate(SOCKET_TIMEOUT)
		} while(main.isLoop)
		return result
	}
	
	override protected internalEvaluate(XExpression expression, IEvaluationContext context, CancelIndicator indicator) throws EvaluationException {
		if(indicator.isCanceled) 
			throw new StoppedException()
		super.internalEvaluate(expression, context, indicator)
	}
	
	override protected invokeOperation(JvmOperation operation, Object receiver, List<Object> argumentValues, IEvaluationContext context, CancelIndicator indicator) {
		val executable = operation.sourceElements.head
		if (executable instanceof Sub) {
			val newContext = baseContext.fork
			var index = 0
			for (param : operation.parameters) {
				newContext.newValue(QualifiedName.create(param.name), argumentValues.get(index))
				index = index + 1	
			}
			val result = evaluate(executable.body, newContext, indicator)
			if(result.exception != null)
				throw result.exception
			result.result
		} else {
			super.invokeOperation(operation, receiver, argumentValues)
		}
	}
	
	override protected featureCallField(JvmField jvmField, Object receiver) {
		val field = jvmField.sourceElements.head
		if(field instanceof Field) 
			baseContext.getValue(QualifiedName.create(field.name))
		else
			super.featureCallField(jvmField, receiver)
	}

	override protected _assigneValueTo(JvmField jvmField, XAbstractFeatureCall assignment, Object value, IEvaluationContext context, CancelIndicator indicator) {
		val field = jvmField.sourceElements.head
		if(field instanceof Field) 
			baseContext.assignValue(QualifiedName.create(field.name), value)
		else
			super._assigneValueTo(jvmField, assignment, value, context, indicator)
		value 
	}
	
}