package org.xtext.mindstorms.xrobot.tests;

import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.xtext.mindstorms.xrobot.Robot;

@SuppressWarnings("all")
public class WeaponTest {
  public static void main(final String[] args) {
    try {
      Brick _default = BrickFinder.getDefault();
      final Robot robot = new Robot(_default);
      while ((!robot.escapePressed())) {
        {
          robot.fireWeapon();
          Thread.sleep(500);
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
