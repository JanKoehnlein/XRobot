package org.xtext.mindstorms.xrobot.tests;

import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.xtext.mindstorms.xrobot.Robot;
import org.xtext.mindstorms.xrobot.geometry.Polar;

@SuppressWarnings("all")
public class EnemyBearingTest {
  public static void main(final String[] args) {
    try {
      Brick _default = BrickFinder.getDefault();
      final Robot robot = new Robot(_default);
      while ((!robot.escapePressed())) {
        {
          Polar _measureEnemyBearing = robot.measureEnemyBearing();
          InputOutput.<Polar>println(_measureEnemyBearing);
          Thread.sleep(500);
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
