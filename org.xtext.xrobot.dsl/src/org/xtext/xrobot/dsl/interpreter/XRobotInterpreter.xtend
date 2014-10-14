package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtext.common.types.JvmDeclaredType
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
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.dsl.interpreter.security.RobotSecurityManager
import org.eclipse.xtext.xbase.XConstructorCall
import org.eclipse.xtext.common.types.util.JavaReflectAccess
import org.xtext.xrobot.api.IRobot

class XRobotInterpreter extends XbaseInterpreter {
	
	static val LOG = Logger.getLogger(XRobotInterpreter)
	
	static val ROBOT_UPDATE_TIMEOUT = 2000
	
	static val ROBOT = QualifiedName.create('Dummy')
	static val CURRENT_LINE = QualifiedName.create('currentLine')

	@Inject extension IJvmModelAssociations
	
	@Inject JavaReflectAccess javaReflectAccess
	
	IEvaluationContext baseContext

	Mode currentMode

	InternalCancelIndicator currentModeCancelIndicator
	
	IRemoteRobot conditionRobot
	
	List<IRobotListener> listeners
	
	Exception lastModeException
	
	def void execute(Program program, IRemoteRobot.Factory robotFactory, List<IRobotListener> listeners, CancelIndicator cancelIndicator) {
		this.listeners = listeners
		baseContext = createContext
		
		try {
			// Start the security manager in order to block all illegal operations
			RobotSecurityManager.start
			
			// Initialize program fields
			for (field: program.fields) {
				if (field.initializer != null) {
					val initialValue = field.initializer.evaluateChecked(baseContext, cancelIndicator)
					baseContext.newValue(QualifiedName.create(field.name), initialValue)
				} else {
					baseContext.newValue(QualifiedName.create(field.name), null)
				}
			}
			
			val conditionCancelIndicator = new InternalCancelIndicator(cancelIndicator)
			conditionRobot = robotFactory.newRobot(conditionCancelIndicator)
			val conditionContext = baseContext.fork()
			conditionContext.newValue(ROBOT, conditionRobot)
			
			do {
				listeners.forEach[stateRead(conditionRobot)]
				if(!conditionCancelIndicator.isCanceled) {
					val newMode = program.modes.findFirst [
						if(condition == null)
							return true
						val result = condition.evaluateChecked(conditionContext, conditionCancelIndicator)
						return result as Boolean ?: false
					]
					if(newMode != currentMode || currentModeCancelIndicator?.isCanceled) {
						if(currentMode != null)
							LOG.debug('Canceling running mode ' +  currentMode.name)
						currentModeCancelIndicator?.cancel
						currentModeCancelIndicator = new InternalCancelIndicator(cancelIndicator)
						currentMode = newMode
						if (newMode != null) {
							
							// Start a new thread executing the activated mode
							LOG.debug('Starting mode ' +  newMode.name)
							val modeRobot = robotFactory.newRobot(currentModeCancelIndicator, conditionRobot)
							val modeContext = baseContext.fork
							modeContext.newValue(ROBOT, modeRobot)
							val modeNode = NodeModelUtils.findActualNodeFor(newMode)
							if (modeNode != null) {
								modeContext.newValue(CURRENT_LINE, modeNode.startLine)
							}
							val threadGroup = Thread.currentThread.threadGroup
							val thread = new Thread(threadGroup,
									'Robot ' + modeRobot.robotID.name + ' in mode ' + newMode.name) {
								override run() {
									try {
										RobotSecurityManager.start
										currentMode.execute(modeContext, currentModeCancelIndicator)
									} catch (CanceledException exc) {
										LOG.debug('Mode ' + newMode.name + ' canceled')
									} catch (Exception exc) {
										LOG.error('Error executing mode ' + newMode.name
											+ " (" + exc.class.simpleName + ")")
										lastModeException = exc
										conditionCancelIndicator.cancel
									} finally {
										currentModeCancelIndicator.cancel
										RobotSecurityManager.stop
									}
								}
							}
							thread.start
							
						}
					}
					Thread.yield
					conditionRobot.waitForUpdate(ROBOT_UPDATE_TIMEOUT)
					if(newMode == null)
						listeners.forEach[ stateChanged(conditionRobot) ]
				}
			} while(!conditionCancelIndicator.isCanceled)
			
			if (lastModeException != null) {
				throw lastModeException
			}
		} finally {
			currentModeCancelIndicator?.cancel
			RobotSecurityManager.stop
		}
	}
	
	protected def execute(Mode mode, IEvaluationContext context, CancelIndicator cancelIndicator) {
		try {
			listeners.forEach[
				val robot = context.getValue(ROBOT) as IRemoteRobot
				modeChanged(robot, mode)
				stateChanged(robot)
			]
			mode.action.evaluateChecked(context, cancelIndicator)
		} catch(CanceledException exc) {
			mode.whenCanceled?.evaluateChecked(context, cancelIndicator)
		}
	}
	
	private def evaluateChecked(XExpression expression, IEvaluationContext context, CancelIndicator indicator) {
		try {
			val result = super.evaluate(expression, context, indicator)
			if (result.exception != null) {
				throw result.exception
			}
			return result.result
		} catch (ExceptionInInitializerError error) {
			throw error.cause
		}
	}
	
	static class InternalCancelIndicator implements CancelIndicator {
		
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
			return evaluateChecked(executable.body, newContext, indicator)
		} else {
			val receiverDeclaredType = javaReflectAccess.getRawType(operation.declaringType)
			if (receiverDeclaredType == IRobot) {
				super.invokeOperation(operation, receiver, argumentValues)
			} else {
				// Make sure our security manager is active while invoking the method
				try {
					RobotSecurityManager.active = true
					System.securityManager.checkPackageAccess(operation.declaringType.packageName)
					return super.invokeOperation(operation, receiver, argumentValues)
				} finally {
					RobotSecurityManager.active = false
				}
			}
		}
	}
	
	override protected _doEvaluate(XConstructorCall constructorCall, IEvaluationContext context, CancelIndicator indicator) {
		// Make sure our security manager is active while invoking the constructor
		try {
			RobotSecurityManager.active = true
			System.securityManager.checkPackageAccess(constructorCall.constructor.declaringType.packageName)
			super._doEvaluate(constructorCall, context, indicator)
		} finally {
			RobotSecurityManager.active = false
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