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
   * The feature id for the '<em><b>Imports</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__IMPORTS = 0;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__NAME = 1;

  /**
   * The feature id for the '<em><b>Author</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__AUTHOR = 2;

  /**
   * The feature id for the '<em><b>Functions</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__FUNCTIONS = 3;

  /**
   * The feature id for the '<em><b>Variables</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__VARIABLES = 4;

  /**
   * The feature id for the '<em><b>Modes</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM__MODES = 5;

  /**
   * The number of structural features of the '<em>Program</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int PROGRAM_FEATURE_COUNT = 6;

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
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.FunctionImpl <em>Function</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.FunctionImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getFunction()
   * @generated
   */
  int FUNCTION = 2;

  /**
   * The feature id for the '<em><b>Return Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FUNCTION__RETURN_TYPE = 0;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FUNCTION__NAME = 1;

  /**
   * The feature id for the '<em><b>Parameters</b></em>' containment reference list.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FUNCTION__PARAMETERS = 2;

  /**
   * The feature id for the '<em><b>Body</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FUNCTION__BODY = 3;

  /**
   * The number of structural features of the '<em>Function</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int FUNCTION_FEATURE_COUNT = 4;

  /**
   * The meta object id for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.VariableImpl <em>Variable</em>}' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.VariableImpl
   * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getVariable()
   * @generated
   */
  int VARIABLE = 3;

  /**
   * The feature id for the '<em><b>Type</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int VARIABLE__TYPE = 0;

  /**
   * The feature id for the '<em><b>Name</b></em>' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int VARIABLE__NAME = 1;

  /**
   * The feature id for the '<em><b>Initializer</b></em>' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int VARIABLE__INITIALIZER = 2;

  /**
   * The number of structural features of the '<em>Variable</em>' class.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   * @ordered
   */
  int VARIABLE_FEATURE_COUNT = 3;


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
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getImports <em>Imports</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Imports</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getImports()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Imports();

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
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getAuthor <em>Author</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Author</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getAuthor()
   * @see #getProgram()
   * @generated
   */
  EAttribute getProgram_Author();

  /**
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getFunctions <em>Functions</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Functions</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getFunctions()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Functions();

  /**
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Program#getVariables <em>Variables</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Variables</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Program#getVariables()
   * @see #getProgram()
   * @generated
   */
  EReference getProgram_Variables();

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
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Function <em>Function</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Function</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Function
   * @generated
   */
  EClass getFunction();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Function#getReturnType <em>Return Type</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Return Type</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Function#getReturnType()
   * @see #getFunction()
   * @generated
   */
  EReference getFunction_ReturnType();

  /**
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Function#getName <em>Name</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Name</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Function#getName()
   * @see #getFunction()
   * @generated
   */
  EAttribute getFunction_Name();

  /**
   * Returns the meta object for the containment reference list '{@link org.xtext.xrobot.dsl.xRobotDSL.Function#getParameters <em>Parameters</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference list '<em>Parameters</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Function#getParameters()
   * @see #getFunction()
   * @generated
   */
  EReference getFunction_Parameters();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Function#getBody <em>Body</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Body</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Function#getBody()
   * @see #getFunction()
   * @generated
   */
  EReference getFunction_Body();

  /**
   * Returns the meta object for class '{@link org.xtext.xrobot.dsl.xRobotDSL.Variable <em>Variable</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for class '<em>Variable</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Variable
   * @generated
   */
  EClass getVariable();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Variable#getType <em>Type</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Type</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Variable#getType()
   * @see #getVariable()
   * @generated
   */
  EReference getVariable_Type();

  /**
   * Returns the meta object for the attribute '{@link org.xtext.xrobot.dsl.xRobotDSL.Variable#getName <em>Name</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the attribute '<em>Name</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Variable#getName()
   * @see #getVariable()
   * @generated
   */
  EAttribute getVariable_Name();

  /**
   * Returns the meta object for the containment reference '{@link org.xtext.xrobot.dsl.xRobotDSL.Variable#getInitializer <em>Initializer</em>}'.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @return the meta object for the containment reference '<em>Initializer</em>'.
   * @see org.xtext.xrobot.dsl.xRobotDSL.Variable#getInitializer()
   * @see #getVariable()
   * @generated
   */
  EReference getVariable_Initializer();

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
     * The meta object literal for the '<em><b>Imports</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__IMPORTS = eINSTANCE.getProgram_Imports();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute PROGRAM__NAME = eINSTANCE.getProgram_Name();

    /**
     * The meta object literal for the '<em><b>Author</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute PROGRAM__AUTHOR = eINSTANCE.getProgram_Author();

    /**
     * The meta object literal for the '<em><b>Functions</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__FUNCTIONS = eINSTANCE.getProgram_Functions();

    /**
     * The meta object literal for the '<em><b>Variables</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference PROGRAM__VARIABLES = eINSTANCE.getProgram_Variables();

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
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.FunctionImpl <em>Function</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.FunctionImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getFunction()
     * @generated
     */
    EClass FUNCTION = eINSTANCE.getFunction();

    /**
     * The meta object literal for the '<em><b>Return Type</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference FUNCTION__RETURN_TYPE = eINSTANCE.getFunction_ReturnType();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute FUNCTION__NAME = eINSTANCE.getFunction_Name();

    /**
     * The meta object literal for the '<em><b>Parameters</b></em>' containment reference list feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference FUNCTION__PARAMETERS = eINSTANCE.getFunction_Parameters();

    /**
     * The meta object literal for the '<em><b>Body</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference FUNCTION__BODY = eINSTANCE.getFunction_Body();

    /**
     * The meta object literal for the '{@link org.xtext.xrobot.dsl.xRobotDSL.impl.VariableImpl <em>Variable</em>}' class.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.VariableImpl
     * @see org.xtext.xrobot.dsl.xRobotDSL.impl.XRobotDSLPackageImpl#getVariable()
     * @generated
     */
    EClass VARIABLE = eINSTANCE.getVariable();

    /**
     * The meta object literal for the '<em><b>Type</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference VARIABLE__TYPE = eINSTANCE.getVariable_Type();

    /**
     * The meta object literal for the '<em><b>Name</b></em>' attribute feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EAttribute VARIABLE__NAME = eINSTANCE.getVariable_Name();

    /**
     * The meta object literal for the '<em><b>Initializer</b></em>' containment reference feature.
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
    EReference VARIABLE__INITIALIZER = eINSTANCE.getVariable_Initializer();

  }

} //XRobotDSLPackage
