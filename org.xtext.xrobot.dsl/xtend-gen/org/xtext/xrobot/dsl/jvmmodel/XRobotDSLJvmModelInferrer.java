package org.xtext.xrobot.dsl.jvmmodel;

import com.google.inject.Inject;
import java.util.Arrays;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.common.types.JvmFormalParameter;
import org.eclipse.xtext.common.types.JvmGenericType;
import org.eclipse.xtext.common.types.JvmMember;
import org.eclipse.xtext.common.types.JvmOperation;
import org.eclipse.xtext.common.types.JvmTypeReference;
import org.eclipse.xtext.xbase.XExpression;
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer;
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor;
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.xtext.mindstorms.xrobot.api.IRobot;
import org.xtext.xrobot.dsl.xRobotDSL.Main;
import org.xtext.xrobot.dsl.xRobotDSL.Program;
import org.xtext.xrobot.dsl.xRobotDSL.Sub;

/**
 * <p>Infers a JVM model from the source model.</p>
 * 
 * <p>The JVM model should contain all elements that would appear in the Java code
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>
 */
@SuppressWarnings("all")
public class XRobotDSLJvmModelInferrer extends AbstractModelInferrer {
  @Inject
  @Extension
  private JvmTypesBuilder _jvmTypesBuilder;
  
  protected void _infer(final Program program, final IJvmDeclaredTypeAcceptor acceptor, final boolean isPreIndexingPhase) {
    String _name = program.getName();
    String _plus = ("org.xtext.xrobot.dsl." + _name);
    JvmGenericType _class = this._jvmTypesBuilder.toClass(program, _plus);
    IJvmDeclaredTypeAcceptor.IPostIndexingInitializing<JvmGenericType> _accept = acceptor.<JvmGenericType>accept(_class);
    final Procedure1<JvmGenericType> _function = new Procedure1<JvmGenericType>() {
      public void apply(final JvmGenericType it) {
        EList<Sub> _subs = program.getSubs();
        for (final Sub sub : _subs) {
          EList<JvmMember> _members = it.getMembers();
          String _name = sub.getName();
          XExpression _body = sub.getBody();
          JvmTypeReference _inferredType = XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.inferredType(_body);
          final Procedure1<JvmOperation> _function = new Procedure1<JvmOperation>() {
            public void apply(final JvmOperation it) {
              EList<JvmFormalParameter> _parameters = it.getParameters();
              EList<JvmFormalParameter> _parameters_1 = sub.getParameters();
              final Function1<JvmFormalParameter, JvmFormalParameter> _function = new Function1<JvmFormalParameter, JvmFormalParameter>() {
                public JvmFormalParameter apply(final JvmFormalParameter it) {
                  String _name = it.getName();
                  JvmTypeReference _parameterType = it.getParameterType();
                  return XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.toParameter(it, _name, _parameterType);
                }
              };
              List<JvmFormalParameter> _map = ListExtensions.<JvmFormalParameter, JvmFormalParameter>map(_parameters_1, _function);
              XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.<JvmFormalParameter>operator_add(_parameters, _map);
              XExpression _body = sub.getBody();
              XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.setBody(it, _body);
            }
          };
          JvmOperation _method = XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.toMethod(sub, _name, _inferredType, _function);
          XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.<JvmOperation>operator_add(_members, _method);
        }
        final Main main = program.getMain();
        EList<JvmMember> _members_1 = it.getMembers();
        final Procedure1<JvmOperation> _function_1 = new Procedure1<JvmOperation>() {
          public void apply(final JvmOperation it) {
            EList<JvmFormalParameter> _parameters = it.getParameters();
            JvmTypeReference _newTypeRef = XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.newTypeRef(main, IRobot.class);
            JvmFormalParameter _parameter = XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.toParameter(main, "it", _newTypeRef);
            XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.<JvmFormalParameter>operator_add(_parameters, _parameter);
            XExpression _body = main.getBody();
            XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.setBody(it, _body);
          }
        };
        JvmOperation _method_1 = XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.toMethod(main, "main", null, _function_1);
        XRobotDSLJvmModelInferrer.this._jvmTypesBuilder.<JvmOperation>operator_add(_members_1, _method_1);
      }
    };
    _accept.initializeLater(_function);
  }
  
  public void infer(final EObject program, final IJvmDeclaredTypeAcceptor acceptor, final boolean isPreIndexingPhase) {
    if (program instanceof Program) {
      _infer((Program)program, acceptor, isPreIndexingPhase);
      return;
    } else if (program != null) {
      _infer(program, acceptor, isPreIndexingPhase);
      return;
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(program, acceptor, isPreIndexingPhase).toString());
    }
  }
}
