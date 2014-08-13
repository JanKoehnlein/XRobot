package org.xtext.mindstorms.xrobot;

import org.xtext.mindstorms.xrobot.IRobot;

@SuppressWarnings("all")
public interface ISubProgram {
  public abstract String getName();
  
  public abstract boolean checkCondition(final IRobot robot);
  
  public abstract int getPriority();
  
  public abstract void run(final IRobot robot);
  
  public abstract void stop(final IRobot robot);
}
