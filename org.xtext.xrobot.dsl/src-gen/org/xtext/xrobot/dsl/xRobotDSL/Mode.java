/**
 */
package org.xtext.xrobot.dsl.xRobotDSL;

import org.eclipse.emf.ecore.EObject;

import org.eclipse.xtext.xbase.XExpression;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Mode</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * </p>
 * <ul>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getName <em>Name</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getCondition <em>Condition</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getAction <em>Action</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getWhenLeft <em>When Left</em>}</li>
 * </ul>
 *
 * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getMode()
 * @model
 * @generated
 */
public interface Mode extends EObject
{
  /**
   * Returns the value of the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Name</em>' attribute isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Name</em>' attribute.
   * @see #setName(String)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getMode_Name()
   * @model
   * @generated
   */
  String getName();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getName <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Name</em>' attribute.
   * @see #getName()
   * @generated
   */
  void setName(String value);

  /**
   * Returns the value of the '<em><b>Condition</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Condition</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Condition</em>' containment reference.
   * @see #setCondition(XExpression)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getMode_Condition()
   * @model containment="true"
   * @generated
   */
  XExpression getCondition();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getCondition <em>Condition</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Condition</em>' containment reference.
   * @see #getCondition()
   * @generated
   */
  void setCondition(XExpression value);

  /**
   * Returns the value of the '<em><b>Action</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Action</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Action</em>' containment reference.
   * @see #setAction(XExpression)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getMode_Action()
   * @model containment="true"
   * @generated
   */
  XExpression getAction();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getAction <em>Action</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Action</em>' containment reference.
   * @see #getAction()
   * @generated
   */
  void setAction(XExpression value);

  /**
   * Returns the value of the '<em><b>When Left</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>When Left</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>When Left</em>' containment reference.
   * @see #setWhenLeft(XExpression)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getMode_WhenLeft()
   * @model containment="true"
   * @generated
   */
  XExpression getWhenLeft();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getWhenLeft <em>When Left</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>When Left</em>' containment reference.
   * @see #getWhenLeft()
   * @generated
   */
  void setWhenLeft(XExpression value);

} // Mode
