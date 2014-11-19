package org.xtext.xrobot.dsl.ui.hover

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.xbase.ui.hover.XbaseHoverDocumentationProvider
import org.xtext.xrobot.dsl.xRobotDSL.Function
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.dsl.xRobotDSL.Variable

class XRobotHoverDocumentationProvider extends XbaseHoverDocumentationProvider {

	public override getDocumentation(EObject object) {
		(object.originalDeclarationInformation ?: computeDocumentation(object)) + object.generalDocumentation
	}

	override protected getDerivedElementInformation(EObject o) {
		null
	}

	override getOriginalDeclarationInformation(EObject o) {
		val sourceElements = getFilteredSourceElements(o, null);
		if (sourceElements.size() > 0) {
			return '''
				«FOR sourceElement : sourceElements»
					«sourceElement.documentation»
				«ENDFOR»
			'''
		} else {
			return null;
		}
	}
	
	protected def dispatch String getGeneralDocumentation(EObject element) {
		''
	}
	
	protected def dispatch String getGeneralDocumentation(Mode mode) '''
		Modes define blocks of behavior for your robot.
		<h3>Condition loop</h3>
		The robot can execute only one mode at a time. A background job
		continuously polls the conditions of all modes in the order they are defined.
		The mode with the first condition that holds will become the new mode.
		If it is the same as the currently executing mode, the execution is continued.
		If it is different, the current mode is canceled and the new mode is started.
		
		<h3>Controlling the Robot</h3>
		The body of a mode in curly braces defines the behavior to be executed. It 
		supports all kinds of Xbase expressions.
		The variable <code>this</code> is bound to an instance of IRobot, which allows 
		you to issue commands and access the robot's state as well as its opponent's
		position.

		<h3>Cancelation and Blocking</h3>
		When a mode is canceled its control flow is immediately stopped.
		If it defines an <code>when canceled</code> block, that one is executed before
		the new mode is started. If a mode is canceled while it is performing a blocking 
		move, that move will continue until the next movement command is issued (either in 
		the cancelation block or by the new mode).
	'''

	protected def dispatch String getGeneralDocumentation(Variable element) '''
		Global variables are accessible in the entire script. You define them in the same way
		as Java fields, but using the <code>var</code> keyword. The type can be omitted
		if it can be inferred from the initializer expression.
	'''

	protected def dispatch String getGeneralDocumentation(Function element) '''
		Use functions to define helper routines. The syntax is the same as in Java, but you
		have to prefix the keyword <code>def</code>. If the return type can be inferred
		from the body, you do not have to declare it. Within a function body you can reach
		your robot through the variable <code>this</code>. As in Java, you can omit
		<code>this.</code> when accessing its features.
	'''

}
