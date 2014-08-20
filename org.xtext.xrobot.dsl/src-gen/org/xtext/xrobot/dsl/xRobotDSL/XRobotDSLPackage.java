/**
 */
package org.xtext.xrobot.dsl.xRobotDSL;

import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EReference;

/**
 * <!-- begin-user-doc -->
 * The <b>Package</b> for the model.
 * It contains accessors for the meta objects to represent
 * <ul>
 *   <li>each class,</li>
 *   <li>each feature of each class,</li>
 *   <li>each enum,</li>
 *   <li>and each data type</li>
 * </ul>
 * <!-- end-user-doc -->
 * @see org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLFactory
 * @model kind="package"
 * @generated
 */
public interface XRobotDSLPackage extends EPackage
{
  /**
   * The package name.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  String eNAME = "xRobotDSL";

  /**
   * The package namespace URI.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  String eNS_URI = "http://www.xtext.org/xrobot/dsl/XRobotDSL";

  /**
   * The package namespace name.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  String eNS_PREFIX = "xRobotDSL";

  /**
   * The singleton instance of the package.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  XRobotDSLPackage eINSTANCE = org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl.init();

  /**
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ProgramImpl <em>Program</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.ProgramImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getProgram()
   * @generated
   */
  int PROGRAM = 0;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__NAME = 0;

  /**
   * The feature id for the '<em><b>Main</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__MAIN = 1;

  /**
   * The feature id for the '<em><b>Subs</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__SUBS = 2;

  /**
   * The number of structural features of the '<em>Program</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM_FEATURE_COUNT = 3;

  /**
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.MainImpl <em>Main</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.MainImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getMain()
   * @generated
   */
  int MAIN = 1;

  /**
   * The feature id for the '<em><b>Body</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MAIN__BODY = 0;

  /**
   * The number of structural features of the '<em>Main</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MAIN_FEATURE_COUNT = 1;

  /**
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.SubImpl <em>Sub</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.SubImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getSub()
   * @generated
   */
  int SUB = 2;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__NAME = 0;

  /**
   * The feature id for the '<em><b>Parameters</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__PARAMETERS = 1;

  /**
   * The feature id for the '<em><b>Body</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__BODY = 2;

  /**
   * The number of structural features of the '<em>Sub</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB_FEATURE_COUNT = 3;


  /**
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Program <em>Program</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Program</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program
   * @generated
   */
  EClass getProgram();

  /**
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getName <em>Name</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Name</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getName()
   * @see #getProgram()
   * @generated
   */
  EAttribute getProgram_Name();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getMain <em>Main</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Main</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getMain()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Main();

  /**
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getSubs <em>Subs</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Subs</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getSubs()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Subs();

  /**
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Main <em>Main</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Main</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Main
   * @generated
   */
  EClass getMain();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Main#getBody <em>Body</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Body</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Main#getBody()
   * @see #getMain()
   * @generated
   */
  EReference getMain_Body();

  /**
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Sub <em>Sub</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Sub</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Sub
   * @generated
   */
  EClass getSub();

  /**
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Sub#getName <em>Name</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Name</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Sub#getName()
   * @see #getSub()
   * @generated
   */
  EAttribute getSub_Name();

  /**
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Sub#getParameters <em>Parameters</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Parameters</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Sub#getParameters()
   * @see #getSub()
   * @generated
   */
  EReference getSub_Parameters();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Sub#getBody <em>Body</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Body</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Sub#getBody()
   * @see #getSub()
   * @generated
   */
  EReference getSub_Body();

  /**
   * Returns the factory that creates the instances of the model.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the factory that creates the instances of the model.
   * @generated
   */
  XRobotDSLFactory getXRobotDSLFactory();

  /**
   * <!-- begin-user-doc -->
   * Defines literals for the meta objects that represent
   * <ul>
   *   <li>each class,</li>
   *   <li>each feature of each class,</li>
   *   <li>each enum,</li>
   *   <li>and each data type</li>
   * </ul>
   * <!-- end-user-doc -->
   * @generated
   */
  interface Literals
  {
    /**
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ProgramImpl <em>Program</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.ProgramImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getProgram()
     * @generated
     */
    EClass PROGRAM = eINSTANCE.getProgram();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute PROGRAM__NAME = eINSTANCE.getProgram_Name();

    /**
     * The meta object literal for the '<em><b>Main</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__MAIN = eINSTANCE.getProgram_Main();

    /**
     * The meta object literal for the '<em><b>Subs</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__SUBS = eINSTANCE.getProgram_Subs();

    /**
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.MainImpl <em>Main</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.MainImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getMain()
     * @generated
     */
    EClass MAIN = eINSTANCE.getMain();

    /**
     * The meta object literal for the '<em><b>Body</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference MAIN__BODY = eINSTANCE.getMain_Body();

    /**
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.SubImpl <em>Sub</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.SubImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getSub()
     * @generated
     */
    EClass SUB = eINSTANCE.getSub();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute SUB__NAME = eINSTANCE.getSub_Name();

    /**
     * The meta object literal for the '<em><b>Parameters</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference SUB__PARAMETERS = eINSTANCE.getSub_Parameters();

    /**
     * The meta object literal for the '<em><b>Body</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference SUB__BODY = eINSTANCE.getSub_Body();

  }

} //XRobotDSLPackage
