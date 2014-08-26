package org.xtext.xrobot.dsl.interpreter

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

class XRobotInterpreter extends XbaseInterpreter implements INetConfig {
	
	static val CANCEL_INDICATOR = QualifiedName.create('cancelIndicator')
	static val IT = QualifiedName.create('it')

	def Object execute(Program program, RemoteRobot robot, CancelIndicator cancelIndicator) {
		val evaluationContext = new DefaultEvaluationContext
		evaluationContext.newValue(IT, robot)
		evaluationContext.newValue(CANCEL_INDICATOR, cancelIndicator)
		val main = program.main
		var Object result = null
		do {
			val startSampleTime = robot.state.sampleTime
			result = main.body.evaluate(evaluationContext, CancelIndicator.NullImpl).result
			while(robot.state.sampleTime == startSampleTime)
				Thread.sleep(UPDATE_INTERVAL / 3);
		} while(main.isLoop)
		return result
	}
	
	
	override protected internalEvaluate(XExpression expression, IEvaluationContext context, CancelIndicator indicator) throws EvaluationException {
		if((context.getValue(CANCEL_INDICATOR) as CancelIndicator).isCanceled) 
			throw new StoppedException()
		super.internalEvaluate(expression, context, indicator)
	}
}