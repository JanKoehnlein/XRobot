package org.xtext.mindstorms.xrobot.tests;

import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.xtext.mindstorms.xrobot.Robot;

@SuppressWarnings("all")
public class ColorSensorTest {
  public static void main(final String[] args) {
    Brick _default = BrickFinder.getDefault();
    final Robot robot = new Robot(_default);
    while ((!robot.escapePressed())) {
      float _measureGroundColor = robot.measureGroundColor();
      InputOutput.<Float>println(Float.valueOf(_measureGroundColor));
    }
  }
}
