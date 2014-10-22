package org.xtext.xrobot.dsl.interpreter

import com.google.inject.Inject
import java.util.HashMap
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmField
import org.eclipse.xtext.common.types.JvmIdentifiableElement
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.common.types.util.JavaReflectAccess
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.xbase.XAbstractFeatureCall
import org.eclipse.xtext.xbase.XConstructorCall
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.interpreter.IEvaluationContext
import org.eclipse.xtext.xbase.interpreter.impl.EvaluationException
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.api.Sample
import org.xtext.xrobot.dsl.interpreter.security.RobotSecurityManager
import org.xtext.xrobot.dsl.xRobotDSL.Field
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.dsl.xRobotDSL.Sub
import org.xtext.xrobot.server.CanceledException
import org.xtext.xrobot.server.IRemoteRobot

import static org.xtext.xrobot.dsl.interpreter.XRobotInterpreter.*
import static org.xtext.xrobot.dsl.interpreter.security.RobotSecurityManager.*

class XRobotInterpreter extends XbaseInterpreter {

	/** Limit on the recursion depth of functions. */
	public static val RECURSION_LIMIT = 100
	/** Limit on the number of elements in allocated arrays. */
	public static val MAX_ARRAY_SIZE = 5000
	/** Limit on the number of calls to {@link IRobot#play(Sample)} and {@link IRobot#say(String)}. */
	public static val NOISE_CALL_LIMIT = 20
	/** Limit on the number of characters in a text string passed to {@link IRobot#say(String)}. */
	public static val SAY_TEXT_LENGTH_LIMIT = 24
	
	static val LOG = Logger.getLogger(XRobotInterpreter)
	
	static val ROBOT_UPDATE_TIMEOUT = 2000
	static val long MIN_FREE_MEMORY = 64 * 1024 * 1024
	
	static val ROBOT = QualifiedName.create('Dummy')
	static val CURRENT_LINE = QualifiedName.create('currentLine')

	@Inject extension IJvmModelAssociations
	
	@Inject JavaReflectAccess javaReflectAccess
	
	@Accessors
	boolean trackLineChanges
	
	IEvaluationContext baseContext

	Mode currentMode

	InternalCancelIndicator currentModeCancelIndicator
	
	IRemoteRobot conditionRobot
	
	List<IRobotListener> listeners
	
	Throwable lastModeException
	
	var int noiseCount
	
	val recursionCounter = new HashMap<JvmOperation, Integer>
	
	def void execute(Program program, IRemoteRobot.Factory robotFactory, List<IRobotListener> listeners, CancelIndicator cancelIndicator) {
		try {
			this.listeners = listeners
			val conditionCancelIndicator = new InternalCancelIndicator(cancelIndicator)
			conditionRobot = robotFactory.newRobot(conditionCancelIndicator)
			baseContext = createContext
			baseContext.newValue(ROBOT, conditionRobot)
			val conditionContext = baseContext.fork()
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
									} catch (Throwable thr) {
										LOG.error('Error executing mode ' + newMode.name
											+ " (" + thr.class.simpleName + ")")
										lastModeException = thr
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
		} catch (CanceledException exc) {
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
			try {
				mode.whenCanceled?.evaluateChecked(context, cancelIndicator)
			} catch(CanceledException exc2) {
				// Ignore exception
			} catch (OutOfMemoryError err) {
				throw new MemoryException("Heap memory limit exceeded", err)
			}
		} catch (OutOfMemoryError err) {
			throw new MemoryException("Heap memory limit exceeded", err)
		}
	}
	
	private def evaluateChecked(XExpression expression, IEvaluationContext context, CancelIndicator indicator) {
		try {
			val result = super.evaluate(expression, context, indicator)
			if (result?.exception != null) {
				throw result.exception
			}
			return result?.result
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
	
	private def getAvailableMemory() {
		val runtime = Runtime.runtime
		runtime.maxMemory() - runtime.totalMemory() + runtime.freeMemory()
	}
	
	override protected internalEvaluate(XExpression expression, IEvaluationContext context, CancelIndicator indicator) throws EvaluationException {
		if (indicator.isCanceled) 
			throw new CanceledException()
		if (trackLineChanges) {
			val node = NodeModelUtils.findActualNodeFor(expression)
			if (node != null) {
				val startLine = node.startLine
				val lastLine = context.getValue(CURRENT_LINE)
				if (lastLine instanceof Integer) {
					if (lastLine.intValue != startLine) {
						context.assignValue(CURRENT_LINE, startLine)
						listeners.forEach[lineChanged(startLine)]
					}
				}
			}
		}
		
		// Check current memory status
		if (availableMemory < MIN_FREE_MEMORY) {
			LOG.info("Program is about to exceed heap memory limit.")
			Runtime.runtime.gc
			if (availableMemory < MIN_FREE_MEMORY) {
				// Garbage collection did not help, so abort program execution
				throw new MemoryException("Heap memory limit exceeded")
			}
		}
		
		super.internalEvaluate(expression, context, indicator)
	}
	
	private def increaseRecursion(JvmOperation operation) {
		synchronized (recursionCounter) {
			val c = recursionCounter.get(operation) ?: 0
			if (c > RECURSION_LIMIT) {
				throw new MemoryException("Recursion limit exceeded by '" + operation.simpleName + "'")
			}
			recursionCounter.put(operation, c + 1)
		}
	}
	
	private def decreaseRecursion(JvmOperation operation) {
		synchronized (recursionCounter) {
			val c = recursionCounter.get(operation)
			if (c == null || c == 0) {
				throw new IllegalStateException
			}
			recursionCounter.put(operation, c - 1)
		}
	}
	
	val sayMethod = IRobot.getMethod("say", String)
	val playMethod = IRobot.getMethod("play", Sample)
	
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
			operation.increaseRecursion
			try {
				return evaluateChecked(executable.body, newContext, indicator)
			} finally {
				operation.decreaseRecursion
			}
		} else {
			val receiverDeclaredType = javaReflectAccess.getRawType(operation.declaringType)
			if (receiverDeclaredType == IRobot) {
				val method = javaReflectAccess.getMethod(operation)
				var blocked = false
				if (method == sayMethod || method == playMethod) {
					if (method == sayMethod) {
						val text = argumentValues.head as String ?: ""
						if (text.length > SAY_TEXT_LENGTH_LIMIT) {
							LOG.info("Command 'say' blocked: text is too long (" + text.length + " characters).")
							blocked = true
						}
					}
					if (noiseCount > NOISE_CALL_LIMIT) {
						LOG.info("Command '" + method.name + "' blocked: robot is too noisy.")
						blocked = true
					}
					noiseCount++
				}
				if (!blocked) {
					super.invokeOperation(operation, receiver, argumentValues)
				}
			} else if (receiverDeclaredType == ArrayLiterals) {
				val size = argumentValues.head as Integer ?: 0
				if (size > MAX_ARRAY_SIZE) {
					throw new MemoryException("Size limit exceeded by array")
				}
				super.invokeOperation(operation, receiver, argumentValues)
			} else {
				operation.increaseRecursion
				try {
					// Make sure our security manager is active while invoking the method
					RobotSecurityManager.active = true
					System.securityManager.checkPackageAccess(operation.declaringType.packageName)
					return super.invokeOperation(operation, receiver, argumentValues)
				} finally {
					RobotSecurityManager.active = false
					operation.decreaseRecursion
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