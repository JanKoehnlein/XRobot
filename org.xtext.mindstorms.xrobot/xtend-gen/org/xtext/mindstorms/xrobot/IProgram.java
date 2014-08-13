package org.xtext.mindstorms.xrobot;

import org.xtext.mindstorms.xrobot.IRobot;
import org.xtext.mindstorms.xrobot.ISubProgram;

@SuppressWarnings("all")
public interface IProgram {
  public abstract void run(final IRobot robot);
  
  public abstract boolean addSubProgram(final ISubProgram sub);
}
