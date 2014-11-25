/**
 */
package org.xtext.xrobot.dsl.xRobotDSL.impl;

import org.eclipse.emf.common.notify.Notification;
import org.eclipse.emf.common.notify.NotificationChain;

import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.InternalEObject;

import org.eclipse.emf.ecore.impl.ENotificationImpl;
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl;

import org.eclipse.xtext.xbase.XExpression;

import org.xtext.xrobot.dsl.xRobotDSL.Mode;
import org.xtext.xrobot.dsl.xRobotDSL.XRobotDSLPackage;

/**
 * <!-- begin-user-doc -->
 * An implementation of the model object '<em><b>Mode</b></em>'.
 * <!-- end-user-doc -->
 * <p>
 * The following features are implemented:
 * <ul>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl#getName <em>Name</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl#getCondition <em>Condition</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl#getAction <em>Action</em>}</li>
 *   <li>{@link org.xtext.xrobot.dsl.xRobotDSL.impl.ModeImpl#getWhenLeft <em>When Left</em>}</li>
 * </ul>
 * </p>
 *
 * @generated
 */
public class ModeImpl extends MinimalEObjectImpl.Container implements Mode
{
  /**
   * The default value of the '{@link #getName() <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getName()
   * @generated
   * @ordered
   */
  protected static final String NAME_EDEFAULT = null;

  /**
   * The cached value of the '{@link #getName() <em>Name</em>}' attribute.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getName()
   * @generated
   * @ordered
   */
  protected String name = NAME_EDEFAULT;

  /**
   * The cached value of the '{@link #getCondition() <em>Condition</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getCondition()
   * @generated
   * @ordered
   */
  protected XExpression condition;

  /**
   * The cached value of the '{@link #getAction() <em>Action</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getAction()
   * @generated
   * @ordered
   */
  protected XExpression action;

  /**
   * The cached value of the '{@link #getWhenLeft() <em>When Left</em>}' containment reference.
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @see #getWhenLeft()
   * @generated
   * @ordered
   */
  protected XExpression whenLeft;

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  protected ModeImpl()
  {
    super();
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  protected EClass eStaticClass()
  {
    return XRobotDSLPackage.Literals.MODE;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public String getName()
  {
    return name;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setName(String newName)
  {
    String oldName = name;
    name = newName;
    if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__NAME, oldName, name));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public XExpression getCondition()
  {
    return condition;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetCondition(XExpression newCondition, NotificationChain msgs)
  {
    XExpression oldCondition = condition;
    condition = newCondition;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__CONDITION, oldCondition, newCondition);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setCondition(XExpression newCondition)
  {
    if (newCondition != condition)
    {
      NotificationChain msgs = null;
      if (condition != null)
        msgs = ((InternalEObject)condition).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - XRobotDSLPackage.MODE__CONDITION, null, msgs);
      if (newCondition != null)
        msgs = ((InternalEObject)newCondition).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - XRobotDSLPackage.MODE__CONDITION, null, msgs);
      msgs = basicSetCondition(newCondition, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__CONDITION, newCondition, newCondition));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public XExpression getAction()
  {
    return action;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetAction(XExpression newAction, NotificationChain msgs)
  {
    XExpression oldAction = action;
    action = newAction;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__ACTION, oldAction, newAction);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setAction(XExpression newAction)
  {
    if (newAction != action)
    {
      NotificationChain msgs = null;
      if (action != null)
        msgs = ((InternalEObject)action).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - XRobotDSLPackage.MODE__ACTION, null, msgs);
      if (newAction != null)
        msgs = ((InternalEObject)newAction).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - XRobotDSLPackage.MODE__ACTION, null, msgs);
      msgs = basicSetAction(newAction, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__ACTION, newAction, newAction));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public XExpression getWhenLeft()
  {
    return whenLeft;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public NotificationChain basicSetWhenLeft(XExpression newWhenLeft, NotificationChain msgs)
  {
    XExpression oldWhenLeft = whenLeft;
    whenLeft = newWhenLeft;
    if (eNotificationRequired())
    {
      ENotificationImpl notification = new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__WHEN_LEFT, oldWhenLeft, newWhenLeft);
      if (msgs == null) msgs = notification; else msgs.add(notification);
    }
    return msgs;
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  public void setWhenLeft(XExpression newWhenLeft)
  {
    if (newWhenLeft != whenLeft)
    {
      NotificationChain msgs = null;
      if (whenLeft != null)
        msgs = ((InternalEObject)whenLeft).eInverseRemove(this, EOPPOSITE_FEATURE_BASE - XRobotDSLPackage.MODE__WHEN_LEFT, null, msgs);
      if (newWhenLeft != null)
        msgs = ((InternalEObject)newWhenLeft).eInverseAdd(this, EOPPOSITE_FEATURE_BASE - XRobotDSLPackage.MODE__WHEN_LEFT, null, msgs);
      msgs = basicSetWhenLeft(newWhenLeft, msgs);
      if (msgs != null) msgs.dispatch();
    }
    else if (eNotificationRequired())
      eNotify(new ENotificationImpl(this, Notification.SET, XRobotDSLPackage.MODE__WHEN_LEFT, newWhenLeft, newWhenLeft));
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public NotificationChain eInverseRemove(InternalEObject otherEnd, int featureID, NotificationChain msgs)
  {
    switch (featureID)
    {
      case XRobotDSLPackage.MODE__CONDITION:
        return basicSetCondition(null, msgs);
      case XRobotDSLPackage.MODE__ACTION:
        return basicSetAction(null, msgs);
      case XRobotDSLPackage.MODE__WHEN_LEFT:
        return basicSetWhenLeft(null, msgs);
    }
    return super.eInverseRemove(otherEnd, featureID, msgs);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public Object eGet(int featureID, boolean resolve, boolean coreType)
  {
    switch (featureID)
    {
      case XRobotDSLPackage.MODE__NAME:
        return getName();
      case XRobotDSLPackage.MODE__CONDITION:
        return getCondition();
      case XRobotDSLPackage.MODE__ACTION:
        return getAction();
      case XRobotDSLPackage.MODE__WHEN_LEFT:
        return getWhenLeft();
    }
    return super.eGet(featureID, resolve, coreType);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eSet(int featureID, Object newValue)
  {
    switch (featureID)
    {
      case XRobotDSLPackage.MODE__NAME:
        setName((String)newValue);
        return;
      case XRobotDSLPackage.MODE__CONDITION:
        setCondition((XExpression)newValue);
        return;
      case XRobotDSLPackage.MODE__ACTION:
        setAction((XExpression)newValue);
        return;
      case XRobotDSLPackage.MODE__WHEN_LEFT:
        setWhenLeft((XExpression)newValue);
        return;
    }
    super.eSet(featureID, newValue);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public void eUnset(int featureID)
  {
    switch (featureID)
    {
      case XRobotDSLPackage.MODE__NAME:
        setName(NAME_EDEFAULT);
        return;
      case XRobotDSLPackage.MODE__CONDITION:
        setCondition((XExpression)null);
        return;
      case XRobotDSLPackage.MODE__ACTION:
        setAction((XExpression)null);
        return;
      case XRobotDSLPackage.MODE__WHEN_LEFT:
        setWhenLeft((XExpression)null);
        return;
    }
    super.eUnset(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public boolean eIsSet(int featureID)
  {
    switch (featureID)
    {
      case XRobotDSLPackage.MODE__NAME:
        return NAME_EDEFAULT == null ? name != null : !NAME_EDEFAULT.equals(name);
      case XRobotDSLPackage.MODE__CONDITION:
        return condition != null;
      case XRobotDSLPackage.MODE__ACTION:
        return action != null;
      case XRobotDSLPackage.MODE__WHEN_LEFT:
        return whenLeft != null;
    }
    return super.eIsSet(featureID);
  }

  /**
   * <!-- begin-user-doc -->
   * <!-- end-user-doc -->
   * @generated
   */
  @Override
  public String toString()
  {
    if (eIsProxy()) return super.toString();

    StringBuffer result = new StringBuffer(super.toString());
    result.append(" (name: ");
    result.append(name);
    result.append(')');
    return result.toString();
  }

} //ModeImpl
