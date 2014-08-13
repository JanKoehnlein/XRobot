package org.xtext.mindstorms.xrobot.tests;

import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.xtext.mindstorms.xrobot.Robot;

@SuppressWarnings("all")
public class ShieldTest {
  public static void main(final String[] args) {
    try {
      Brick _default = BrickFinder.getDefault();
      final Robot robot = new Robot(_default);
      while ((!robot.escapePressed())) {
        {
          float _measureShieldContact = robot.measureShieldContact();
          InputOutput.<Float>println(Float.valueOf(_measureShieldContact));
          Thread.sleep(500);
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
