package org.xtext.mindstorms.xrobot;

import lejos.hardware.Brick;
import lejos.hardware.BrickFinder;
import lejos.hardware.Button;
import org.eclipse.xtext.xbase.lib.Extension;
import org.xtext.mindstorms.xrobot.IRobot;
import org.xtext.mindstorms.xrobot.ISubProgram;
import org.xtext.mindstorms.xrobot.Program;
import org.xtext.mindstorms.xrobot.Robot;
import org.xtext.mindstorms.xrobot.geometry.Polar;
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
      final Robot robot = new Robot(brick);
      final Program program = new Program();
      program.addSubProgram(new ISubProgram() {
        public String getName() {
          return "seek";
        }
        
        public boolean checkCondition(final IRobot robot) {
          return true;
        }
        
        public int getPriority() {
          return 0;
        }
        
        public void run(final IRobot robot) {
          robot.curveForward(10, 360);
        }
        
        public void stop(final IRobot robot) {
          robot.stop();
        }
      });
      program.addSubProgram(new ISubProgram() {
        public String getName() {
          return "punch";
        }
        
        public boolean checkCondition(final IRobot robot) {
          final Polar enemyBearing = robot.measureEnemyBearing();
          boolean _or = false;
          boolean _and = false;
          float _angle = enemyBearing.getAngle();
          float _abs = Math.abs(_angle);
          boolean _lessThan = (_abs < 3);
          if (!_lessThan) {
            _and = false;
          } else {
            float _distance = enemyBearing.getDistance();
            boolean _lessThan_1 = (_distance < 10);
            _and = _lessThan_1;
          }
          if (_and) {
            _or = true;
          } else {
            float _measureShieldContact = robot.measureShieldContact();
            boolean _greaterThan = (_measureShieldContact > 0.5);
            _or = _greaterThan;
          }
          return _or;
        }
        
        public int getPriority() {
          return 25;
        }
        
        public void run(final IRobot robot) {
          robot.fireWeapon();
        }
        
        public void stop(final IRobot robot) {
        }
      });
      program.addSubProgram(new ISubProgram() {
        public String getName() {
          return "attack";
        }
        
        public boolean checkCondition(final IRobot robot) {
          boolean _xblockexpression = false;
          {
            final Polar enemyBearing = robot.measureEnemyBearing();
            boolean _and = false;
            boolean _isValid = enemyBearing.isValid();
            if (!_isValid) {
              _and = false;
            } else {
              float _angle = enemyBearing.getAngle();
              float _abs = Math.abs(_angle);
              boolean _lessThan = (_abs < 12);
              _and = _lessThan;
            }
            _xblockexpression = _and;
          }
          return _xblockexpression;
        }
        
        public int getPriority() {
          return 20;
        }
        
        public void run(final IRobot robot) {
          final Polar enemyBearing = robot.measureEnemyBearing();
          robot.curveTo(enemyBearing);
        }
        
        public void stop(final IRobot robot) {
        }
      });
      program.addSubProgram(new ISubProgram() {
        public String getName() {
          return "face enemy";
        }
        
        public boolean checkCondition(final IRobot robot) {
          boolean _xblockexpression = false;
          {
            final Polar enemyBearing = robot.measureEnemyBearing();
            _xblockexpression = enemyBearing.isValid();
          }
          return _xblockexpression;
        }
        
        public int getPriority() {
          return 10;
        }
        
        public void run(final IRobot robot) {
          Polar _measureEnemyBearing = robot.measureEnemyBearing();
          final float angle = _measureEnemyBearing.getAngle();
          robot.rotate((((-90) * angle) / 25));
        }
        
        public void stop(final IRobot robot) {
        }
      });
      program.run(robot);
      _xblockexpression = Button.waitForAnyPress();
    }
    return _xblockexpression;
  }
}
