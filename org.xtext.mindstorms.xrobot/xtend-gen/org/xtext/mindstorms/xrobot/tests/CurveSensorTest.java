package org.xtext.mindstorms.xrobot.tests;

import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import org.xtext.mindstorms.xrobot.Robot;

@SuppressWarnings("all")
public class CurveSensorTest {
  public static void main(final String[] args) {
    Brick _default = BrickFinder.getDefault();
    final Robot robot = new Robot(_default);
    while ((!robot.escapePressed())) {
      robot.curveForward(20, 360);
    }
  }
}
