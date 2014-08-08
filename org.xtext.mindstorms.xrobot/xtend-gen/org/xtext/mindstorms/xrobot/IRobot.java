package org.xtext.mindstorms.xrobot;

import org.xtext.mindstorms.xrobot.geometry.Point;
import org.xtext.mindstorms.xrobot.geometry.Polar;

@SuppressWarnings("all")
public interface IRobot {
  public abstract Point getPosition();
  
  public abstract double getBearing();
  
  /**
   * @param angle in degrees
   */
  public abstract void rotate(final double angle);
  
  /**
   * @param distance in cm
   */
  public abstract void forward(final double distance);
  
  /**
   * @param distance in cm
   */
  public abstract void backward(final double distance);
  
  public abstract double measureDistance();
  
  public abstract Polar measureEnemyBearing();
  
  public abstract double measureGroundColor();
}
