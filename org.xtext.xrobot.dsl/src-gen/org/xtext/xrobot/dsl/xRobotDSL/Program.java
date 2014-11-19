/**
 */
package org.xtext.xrobot.dsl.xRobotDSL;

import org.eclipse.emf.common.util.EList;

import org.eclipse.emf.ecore.EObject;

import org.eclipse.xtext.xtype.XImportSection;

/**
 * <!-- begin-user-doc -->
 * A representation of the model object '<em><b>Program</b></em>'.
 * <!-- end-user-doc -->
 *
 * <p>
 * The following features are supported:
 * <ul>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getImports <em>Imports</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getName <em>Name</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getAuthor <em>Author</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getFunctions <em>Functions</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getVariables <em>Variables</em>}</li>
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
   * Returns the value of the '<em><b>Imports</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Imports</em>' containment reference isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Imports</em>' containment reference.
   * @see #setImports(XImportSection)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Imports()
   * @model containment="true"
   * @generated
   */
  XImportSection getImports();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getImports <em>Imports</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Imports</em>' containment reference.
   * @see #getImports()
   * @generated
   */
  void setImports(XImportSection value);

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
   * Returns the value of the '<em><b>Author</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Author</em>' attribute isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Author</em>' attribute.
   * @see #setAuthor(String)
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Author()
   * @model
   * @generated
   */
  String getAuthor();

  /**
   * Sets the value of the '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getAuthor <em>Author</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @param value the new value of the '<em>Author</em>' attribute.
   * @see #getAuthor()
   * @generated
   */
  void setAuthor(String value);

  /**
   * Returns the value of the '<em><b>Functions</b></em>' containment reference list.
   * The list contents are of type {@link org.xtext.xrobot.dsl.xRobotDSL.Function}.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Functions</em>' containment reference list isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Functions</em>' containment reference list.
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Functions()
   * @model containment="true"
   * @generated
   */
  EList<Function> getFunctions();

  /**
   * Returns the value of the '<em><b>Variables</b></em>' containment reference list.
   * The list contents are of type {@link org.xtext.xrobot.dsl.xRobotDSL.Variable}.
   * <!-- begin-user-doc -->
   * <p>
   * If the meaning of the '<em>Variables</em>' containment reference list isn't clear,
   * there really should be more of a description here...
   * </p>
   * <!-- end-user-doc -->
   * @return the value of the '<em>Variables</em>' containment reference list.
   * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage#getProgram_Variables()
   * @model containment="true"
   * @generated
   */
  EList<Variable> getVariables();

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
