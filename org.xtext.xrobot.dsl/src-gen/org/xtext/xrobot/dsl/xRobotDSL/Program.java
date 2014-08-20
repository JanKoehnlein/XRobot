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
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getName <em>Name</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getMain <em>Main</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getSubs <em>Subs</em>}</li>
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
   * Returns the value of the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Name</em>' attribute isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Name</em>' attribute.
   * @see #setName(String)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Name()
   * @model
   * @generated
   */
  String getName();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getName <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Name</em>' attribute.
   * @see #getName()
   * @generated
   */
  void setName(String value);

  /**
   * Returns the value of the '<em><b>Main</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Main</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Main</em>' containment reference.
   * @see #setMain(Main)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Main()
   * @model containment="true"
   * @generated
   */
  Main getMain();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getMain <em>Main</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Main</em>' containment reference.
   * @see #getMain()
   * @generated
   */
  void setMain(Main value);

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

} // Program
