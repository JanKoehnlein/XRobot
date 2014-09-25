package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtext.common.types.JvmField
import org.eclipse.xtext.common.types.JvmIdentifiableElement
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.xbase.XAbstractFeatureCall
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.EvaluationException
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations
import org.xtext.xrobot.dsl.xRobotDSL.Field
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.dsl.xRobotDSL.Sub
import org.xtext.xrobot.net.INetConfig
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobot
import org.eclipse.xtext.common.types.JvmDeclaredType

class XRobotInterpreter extends XbaseInterpreter implements INetConfig {
	
	static val LOG = Logger.getLogger(XRobotInterpreter)
	
	static val ROBOT = QualifiedName.create('Dummy')
	static val CURRENT_LINE = QualifiedName.create('currentLine')

	IEvaluationContext baseContext

	Mode currentMode

	ModeCancelIndicator currentModeCancelIndicator
	
	IRemoteRobot conditionRobot
	
	@Inject extension IJvmModelAssociations 
	
	List<IRobotListener> listeners
	
	def void execute(Program program, IRemoteRobot.Factory robotFactory, List<IRobotListener> listeners, CancelIndicator cancelIndicator) {
		this.listeners = listeners
		baseContext = createContext
		for(field: program.fields) {
			if(field.initializer != null) {
				val initialValue = field.initializer.evaluate(baseContext, cancelIndicator)
				baseContext.newValue(QualifiedName.create(field.name), initialValue.result)
			} else {
				baseContext.newValue(QualifiedName.create(field.name), null)
			}
		}
		conditionRobot = robotFactory.newRobot(cancelIndicator)
		val conditionContext = baseContext.fork()
		conditionContext.newValue(ROBOT, conditionRobot)
		try {
			do {
//				LOG.debug('Checking mode conditions')
				listeners.forEach[stateRead(conditionRobot)]
				if(!cancelIndicator.isCanceled) {
					val newMode = program.modes.findFirst [
						if(condition == null)
							return true
						val result = condition?.evaluate(conditionContext, cancelIndicator)
						return result != null && result?.result as Boolean
					]		
					if(newMode != currentMode || currentModeCancelIndicator?.isCanceled) {
						if(currentMode != null)
							LOG.debug('Canceling running mode ' +  currentMode.name)
						currentModeCancelIndicator?.cancel
						currentModeCancelIndicator = new ModeCancelIndicator(cancelIndicator)
						currentMode = newMode
						if (newMode != null) {
							LOG.debug('Starting mode ' +  newMode.name)
							val modeRobot = robotFactory.newRobot(currentModeCancelIndicator, conditionRobot)
							val modeContext = baseContext.fork
							modeContext.newValue(ROBOT, modeRobot)
							val modeNode = NodeModelUtils.findActualNodeFor(newMode)
							if (modeNode != null) {
								modeContext.newValue(CURRENT_LINE, modeNode.startLine)
							}
							new Thread([
									try {
										currentMode.execute(modeContext, currentModeCancelIndicator)
									} catch (CanceledException exc) {
										LOG.debug('Mode ' + newMode.name + ' canceled')
									} catch (Exception exc) {
										LOG.error('Error executing mode ' + newMode.name, exc)
									} finally {
										currentModeCancelIndicator.cancel
									}
								], 'Robot ' + modeRobot.name + ' in mode ' + newMode.name)
								.start
						}
					}
					Thread.yield
					conditionRobot.waitForUpdate(SOCKET_TIMEOUT)
					if(newMode == null)
						listeners.forEach[ stateChanged(conditionRobot) ]
				}
			} while(!cancelIndicator.canceled)
		} catch(CanceledException exc) {
		}
	}
	
	protected def execute(Mode mode, IEvaluationContext context, CancelIndicator cancelIndicator) {
		try {
			listeners.forEach[
				val robot = context.getValue(ROBOT) as RemoteRobot
				modeChanged(robot, mode)
				stateChanged(robot)
			]
			mode.action.evaluate(context, cancelIndicator)
		} catch(CanceledException exc) {
			mode.whenCanceled?.evaluate(context, cancelIndicator)
		}
	}
	
	static class ModeCancelIndicator implements CancelIndicator {
		
		CancelIndicator baseCancelindicator
		boolean canceled
		
		new(CancelIndicator baseCancelindicator) {
			this.baseCancelindicator = baseCancelindicator
		}
		
		def void cancel() {
			canceled = true
		}
		
		override isCanceled() {
			canceled || baseCancelindicator.canceled 
		}
	}
	
	override protected internalEvaluate(XExpression expression, IEvaluationContext context, CancelIndicator indicator) throws EvaluationException {
		if(indicator.isCanceled) 
			throw new CanceledException()
		val node = NodeModelUtils.findActualNodeFor(expression)
		if(node != null) {
			val startLine = node.startLine
			val lastLine = context.getValue(CURRENT_LINE)
			if(lastLine instanceof Integer) {
				if(lastLine.intValue != startLine) {
					context.assignValue(CURRENT_LINE, startLine)
					listeners.forEach[lineChanged(startLine)]
				}
			}
		}
		super.internalEvaluate(expression, context, indicator)
	}
	
	override protected invokeOperation(JvmOperation operation, Object receiver, List<Object> argumentValues, IEvaluationContext context, CancelIndicator indicator) {
		val executable = operation.sourceElements.head
		if (executable instanceof Sub) {
			val newContext = baseContext.fork
			newContext.newValue(ROBOT, context.getValue(ROBOT))
			var index = 0
			for (param : operation.parameters) {
				newContext.newValue(QualifiedName.create(param.name), argumentValues.get(index))
				index = index + 1	
			}
			val result = evaluate(executable.body, newContext, indicator)
			if (result.exception != null) {
				throw new EvaluationException(result.exception) 
			}
			return result.result
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
		if(field instanceof Field) {
			context.assignValue(QualifiedName.create(field.name), value)
			listeners.forEach[variableChanged(field.name, value)]
		} else {
			super._assigneValueTo(jvmField, assignment, value, context, indicator)
		}
		value 
	}
	
	override Object _invokeFeature(JvmIdentifiableElement identifiable, XAbstractFeatureCall featureCall, Object receiver,
			IEvaluationContext context, CancelIndicator indicator) {
		if(identifiable instanceof JvmDeclaredType) 
			return context.getValue(ROBOT)
		else 
			return super._invokeFeature(identifiable, featureCall, receiver, context, indicator)
			
	}
}