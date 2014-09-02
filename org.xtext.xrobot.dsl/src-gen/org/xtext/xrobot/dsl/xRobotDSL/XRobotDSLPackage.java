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
   * The feature id for the '<em><b>Subs</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__SUBS = 0;

  /**
   * The feature id for the '<em><b>Fields</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__FIELDS = 1;

  /**
   * The feature id for the '<em><b>Modes</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__MODES = 2;

  /**
   * The number of structural features of the '<em>Program</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM_FEATURE_COUNT = 3;

  /**
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl <em>Mode</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getMode()
   * @generated
   */
  int MODE = 1;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MODE__NAME = 0;

  /**
   * The feature id for the '<em><b>Condition</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MODE__CONDITION = 1;

  /**
   * The feature id for the '<em><b>Action</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MODE__ACTION = 2;

  /**
   * The feature id for the '<em><b>When Canceled</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MODE__WHEN_CANCELED = 3;

  /**
   * The number of structural features of the '<em>Mode</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int MODE_FEATURE_COUNT = 4;

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
   * The feature id for the '<em><b>Return Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__RETURN_TYPE = 0;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__NAME = 1;

  /**
   * The feature id for the '<em><b>Parameters</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__PARAMETERS = 2;

  /**
   * The feature id for the '<em><b>Body</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB__BODY = 3;

  /**
   * The number of structural features of the '<em>Sub</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int SUB_FEATURE_COUNT = 4;

  /**
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.FieldImpl <em>Field</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.FieldImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getField()
   * @generated
   */
  int FIELD = 3;

  /**
   * The feature id for the '<em><b>Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FIELD__TYPE = 0;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FIELD__NAME = 1;

  /**
   * The feature id for the '<em><b>Initializer</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FIELD__INITIALIZER = 2;

  /**
   * The number of structural features of the '<em>Field</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FIELD_FEATURE_COUNT = 3;


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
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getFields <em>Fields</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Fields</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getFields()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Fields();

  /**
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getModes <em>Modes</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Modes</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getModes()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Modes();

  /**
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode <em>Mode</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Mode</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Mode
   * @generated
   */
  EClass getMode();

  /**
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getName <em>Name</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Name</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Mode#getName()
   * @see #getMode()
   * @generated
   */
  EAttribute getMode_Name();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getCondition <em>Condition</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Condition</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Mode#getCondition()
   * @see #getMode()
   * @generated
   */
  EReference getMode_Condition();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getAction <em>Action</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Action</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Mode#getAction()
   * @see #getMode()
   * @generated
   */
  EReference getMode_Action();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Mode#getWhenCanceled <em>When Canceled</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>When Canceled</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Mode#getWhenCanceled()
   * @see #getMode()
   * @generated
   */
  EReference getMode_WhenCanceled();

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
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Sub#getReturnType <em>Return Type</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Return Type</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Sub#getReturnType()
   * @see #getSub()
   * @generated
   */
  EReference getSub_ReturnType();

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
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Field <em>Field</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Field</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Field
   * @generated
   */
  EClass getField();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Field#getType <em>Type</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Type</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Field#getType()
   * @see #getField()
   * @generated
   */
  EReference getField_Type();

  /**
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Field#getName <em>Name</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Name</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Field#getName()
   * @see #getField()
   * @generated
   */
  EAttribute getField_Name();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Field#getInitializer <em>Initializer</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Initializer</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Field#getInitializer()
   * @see #getField()
   * @generated
   */
  EReference getField_Initializer();

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
     * The meta object literal for the '<em><b>Subs</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__SUBS = eINSTANCE.getProgram_Subs();

    /**
     * The meta object literal for the '<em><b>Fields</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__FIELDS = eINSTANCE.getProgram_Fields();

    /**
     * The meta object literal for the '<em><b>Modes</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__MODES = eINSTANCE.getProgram_Modes();

    /**
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl <em>Mode</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getMode()
     * @generated
     */
    EClass MODE = eINSTANCE.getMode();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute MODE__NAME = eINSTANCE.getMode_Name();

    /**
     * The meta object literal for the '<em><b>Condition</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference MODE__CONDITION = eINSTANCE.getMode_Condition();

    /**
     * The meta object literal for the '<em><b>Action</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference MODE__ACTION = eINSTANCE.getMode_Action();

    /**
     * The meta object literal for the '<em><b>When Canceled</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference MODE__WHEN_CANCELED = eINSTANCE.getMode_WhenCanceled();

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
     * The meta object literal for the '<em><b>Return Type</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference SUB__RETURN_TYPE = eINSTANCE.getSub_ReturnType();

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

    /**
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.FieldImpl <em>Field</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.FieldImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getField()
     * @generated
     */
    EClass FIELD = eINSTANCE.getField();

    /**
     * The meta object literal for the '<em><b>Type</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference FIELD__TYPE = eINSTANCE.getField_Type();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute FIELD__NAME = eINSTANCE.getField_Name();

    /**
     * The meta object literal for the '<em><b>Initializer</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference FIELD__INITIALIZER = eINSTANCE.getField_Initializer();

  }

} //XRobotDSLPackage
