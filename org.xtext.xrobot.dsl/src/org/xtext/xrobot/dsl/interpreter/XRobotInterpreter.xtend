package org.xtext.xrobot.dsl.interpreter

import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.DefaultEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.EvaluationException
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter
import org.xtext.mindstorms.xrobot.net.INetConfig
import org.xtext.mindstorms.xrobot.server.RemoteRobot
import org.xtext.xrobot.dsl.xRobotDSL.Program

class XRobotInterpreter extends XbaseInterpreter implements INetConfig {
	
	def Object execute(Program program, RemoteRobot robot) {
		val evaluationContext = new DefaultEvaluationContext
		evaluationContext.newValue(QualifiedName.create('it'), robot)
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
		if(System.in.available > 0)
			throw new StoppedException()
		super.internalEvaluate(expression, context, indicator)
	}
}