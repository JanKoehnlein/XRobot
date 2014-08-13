package org.xtext.mindstorms.xrobot;

import org.xtext.mindstorms.xrobot.geometry.Polar;

@SuppressWarnings("all")
public interface IRobot {
  public abstract void forward(final double distance);
  
  public abstract void backward(final double distance);
  
  public abstract void setTravelSpeed(final double speed);
  
  public abstract double getTravelSpeed();
  
  public abstract double getMaxTravelSpeed();
  
  public abstract void rotate(final double angle);
  
  public abstract void setRotateSpeed(final double speed);
  
  public abstract double getRotateSpeed();
  
  public abstract double getRotateMaxSpeed();
  
  public abstract void curveForward(final double radius, final double angle);
  
  public abstract void curveBackward(final double radius, final double angle);
  
  public abstract void curveTo(final Polar bearing);
  
  public abstract void stop();
  
  public abstract float measureDistance();
  
  public abstract Polar measureEnemyBearing();
  
  public abstract float measureGroundColor();
  
  public abstract float measureShieldContact();
  
  public abstract boolean escapePressed();
  
  public abstract void fireWeapon();
}
