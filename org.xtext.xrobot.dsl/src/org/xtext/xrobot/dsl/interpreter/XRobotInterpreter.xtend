package org.xtext.xrobot.dsl.interpreter

import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.DefaultEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.EvaluationException
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.RemoteRobot
import java.util.List
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations
import com.google.inject.Inject
import org.xtext.xrobot.dsl.xRobotDSL.Sub

class XRobotInterpreter extends XbaseInterpreter implements INetConfig {
	
	static val CANCEL_INDICATOR = QualifiedName.create('cancelIndicator')
	static val IT = QualifiedName.create('it')
	
	@Inject extension IJvmModelAssociations 
	
	def Object execute(Program program, RemoteRobot robot, CancelIndicator cancelIndicator) {
		val evaluationContext = new DefaultEvaluationContext
		evaluationContext.newValue(IT, robot)
		evaluationContext.newValue(CANCEL_INDICATOR, cancelIndicator)
		for(field: program.fields) {
			if(field.initializer != null) {
				val initialValue = field.initializer.evaluate(evaluationContext, cancelIndicator)
				evaluationContext.newValue(QualifiedName.create(field.name), initialValue)
			}
		}
		val main = program.main
		var Object result = null
		do {
			result = main.body.evaluate(evaluationContext, cancelIndicator).result
			robot.waitForUpdate(SOCKET_TIMEOUT)
		} while(main.isLoop)
		return result
	}
	
	override protected internalEvaluate(XExpression expression, IEvaluationContext context, CancelIndicator indicator) throws EvaluationException {
		if((context.getValue(CANCEL_INDICATOR) as CancelIndicator).isCanceled) 
			throw new StoppedException()
		super.internalEvaluate(expression, context, indicator)
	}
	
	override protected invokeOperation(JvmOperation operation, Object receiver, List<Object> argumentValues, IEvaluationContext context, CancelIndicator indicator) {
		val executable = operation.sourceElements.head
		if (executable instanceof Sub) {
			val cancelIndicator = context.getValue(CANCEL_INDICATOR) as CancelIndicator
			val newContext = createContext
			newContext.newValue(CANCEL_INDICATOR, cancelIndicator)
			var index = 0
			for (param : operation.parameters) {
				newContext.newValue(QualifiedName.create(param.name), argumentValues.get(index))
				index = index + 1	
			}
			val result = evaluate(executable.body, newContext, cancelIndicator)
			if(result.exception != null)
				throw result.exception
			result.result
		} else {
			super.invokeOperation(operation, receiver, argumentValues)
		}
	}
	
}