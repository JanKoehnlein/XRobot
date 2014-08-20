package org.xtext.xrobot.dsl.interpreter;

import org.eclipse.xtext.naming.QualifiedName;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.xbase.XExpression;
import org.eclipse.xtext.xbase.interpreter.IEvaluationResult;
import org.eclipse.xtext.xbase.interpreter.impl.DefaultEvaluationContext;
import org.eclipse.xtext.xbase.interpreter.impl.XbaseInterpreter;
import org.xtext.mindstorms.xrobot.api.IRobot;
import org.xtext.xrobot.dsl.xRobotDSL.Main;
import org.xtext.xrobot.dsl.xRobotDSL.Program;

@SuppressWarnings("all")
public class XRobotInterpreter extends XbaseInterpreter {
  public Object execute(final Program program, final IRobot robot) {
    final DefaultEvaluationContext evaluationContext = new DefaultEvaluationContext();
    QualifiedName _create = QualifiedName.create("it");
    evaluationContext.newValue(_create, robot);
    Main _main = program.getMain();
    XExpression _body = _main.getBody();
    final IEvaluationResult result = this.evaluate(_body, evaluationContext, CancelIndicator.NullImpl);
    return result.getResult();
  }
}
