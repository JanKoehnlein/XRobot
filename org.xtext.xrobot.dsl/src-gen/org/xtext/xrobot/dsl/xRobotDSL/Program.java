/**
 */
package org.xtext.xrobot.dsl.xRobotDSL;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EObject;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Program</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * <ul>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getSubs <em>Subs</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getFields <em>Fields</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getModes <em>Modes</em>}</li>
 * </ul>
 * </p>
 *
 * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram()
 * @model
 * @generated
 */
public interface Program extends EObject
{
  /**
   * Returns the value of the '<em><b>Subs</b></em>' containment reference list.
   * The list contents are of type {@link org.xtext.xrobot.dsl.xRobotDSL.Sub}.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Subs</em>' containment reference list isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Subs</em>' containment reference list.
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Subs()
   * @model containment="true"
   * @generated
   */
  EList<Sub> getSubs();

  /**
   * Returns the value of the '<em><b>Fields</b></em>' containment reference list.
   * The list contents are of type {@link org.xtext.xrobot.dsl.xRobotDSL.Field}.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Fields</em>' containment reference list isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Fields</em>' containment reference list.
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Fields()
   * @model containment="true"
   * @generated
   */
  EList<Field> getFields();

  /**
   * Returns the value of the '<em><b>Modes</b></em>' containment reference list.
   * The list contents are of type {@link org.xtext.xrobot.dsl.xRobotDSL.Mode}.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Modes</em>' containment reference list isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Modes</em>' containment reference list.
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Modes()
   * @model containment="true"
   * @generated
   */
  EList<Mode> getModes();

} // Program
