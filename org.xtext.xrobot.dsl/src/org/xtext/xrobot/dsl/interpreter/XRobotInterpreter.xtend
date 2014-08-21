package org.xtext.xrobot.dsl.interpreter

import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.xbase.interpreter.impl.DefaultEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter
import org.xtext.mindstorms.xrobot.api.IRobot
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.EvaluationException

class XRobotInterpreter extends XbaseInterpreter {
	
	def Object execute(Program program, IRobot robot) {
		val evaluationContext = new DefaultEvaluationContext
		evaluationContext.newValue(QualifiedName.create('it'), robot)
		val result = program.main.body.evaluate(evaluationContext, CancelIndicator.NullImpl)
		return result.result
	}
	
	override protected internalEvaluate(XExpression expression, IEvaluationContext context, CancelIndicator indicator) throws EvaluationException {
		if(System.in.available > 0)
			throw new StoppedException()
		super.internalEvaluate(expression, context, indicator)
	}
	
}