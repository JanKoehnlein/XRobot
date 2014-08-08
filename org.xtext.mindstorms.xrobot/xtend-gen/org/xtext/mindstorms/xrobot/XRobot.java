package org.xtext.mindstorms.xrobot;

import lejos.hardware.Audio;
import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import lejos.hardware.Button;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IntegerRange;
import org.xtext.mindstorms.xrobot.Robot;
import org.xtext.mindstorms.xrobot.geometry.Point;
import org.xtext.mindstorms.xrobot.util.SoundUtil;

@SuppressWarnings("all")
public class XRobot {
  @Extension
  private SoundUtil soundUtil = new SoundUtil();
  
  public static void main(final String[] args) {
    XRobot _xRobot = new XRobot();
    _xRobot.run();
  }
  
  public int run() {
    int _xblockexpression = (int) 0;
    {
      final Brick brick = BrickFinder.getDefault();
      Audio _audio = brick.getAudio();
      this.soundUtil.playSample(_audio, "samples/futile.wav", 100);
      final Robot robot = new Robot(brick);
      IntegerRange _upTo = new IntegerRange(1, 4);
      for (final Integer i : _upTo) {
        {
          robot.rotate(90);
          robot.forward(100);
          Point _position = robot.getPosition();
          InputOutput.<Point>println(_position);
        }
      }
      _xblockexpression = Button.waitForAnyPress();
    }
    return _xblockexpression;
  }
}
