package org.xtext.xrobot.dsl;

import org.eclipse.xtext.xbase.lib.InputOutput;
import org.xtext.mindstorms.xrobot.api.IMotor;
import org.xtext.mindstorms.xrobot.api.IRobot;
import org.xtext.mindstorms.xrobot.data.SensorSample;

@SuppressWarnings("all")
public class Foo {
  public void main(final IRobot it) {
    IMotor _leftMotor = it.getLeftMotor();
    double maxSpeed = _leftMotor.getMaxSpeed();
    SensorSample data = it.sample();
    while (data.isEnemyDetected()) {
      {
        IMotor _leftMotor_1 = it.getLeftMotor();
        _leftMotor_1.forward();
        IMotor _rightMotor = it.getRightMotor();
        _rightMotor.forward();
        InputOutput.<Double>println(Double.valueOf(maxSpeed));
        SensorSample _sample = it.sample();
        data = _sample;
        while ((data.isEnemyDetected() && (data.getEnemyDistanceInCentimeter() > 40))) {
          {
            double _enemyAngleInDegrees = data.getEnemyAngleInDegrees();
            double _divide = (_enemyAngleInDegrees / 2);
            double _plus = (45 + _divide);
            double _multiply = (0.02 * _plus);
            double _multiply_1 = (_multiply * maxSpeed);
            final int left = ((int) _multiply_1);
            double _enemyAngleInDegrees_1 = data.getEnemyAngleInDegrees();
            double _divide_1 = (_enemyAngleInDegrees_1 / 2);
            double _minus = (45 - _divide_1);
            double _multiply_2 = (0.02 * _minus);
            double _multiply_3 = (_multiply_2 * maxSpeed);
            final int right = ((int) _multiply_3);
            double _enemyAngleInDegrees_2 = data.getEnemyAngleInDegrees();
            String _plus_1 = ((((("left=" + Integer.valueOf(left)) + "  right=") + Integer.valueOf(right)) + "  angle=") + Double.valueOf(_enemyAngleInDegrees_2));
            String _plus_2 = (_plus_1 + "  distance=");
            double _enemyDistanceInCentimeter = data.getEnemyDistanceInCentimeter();
            String _plus_3 = (_plus_2 + Double.valueOf(_enemyDistanceInCentimeter));
            InputOutput.<String>println(_plus_3);
            IMotor _leftMotor_2 = it.getLeftMotor();
            _leftMotor_2.setSpeed(left);
            IMotor _rightMotor_1 = it.getRightMotor();
            _rightMotor_1.setSpeed(right);
            SensorSample _sample_1 = it.sample();
            data = _sample_1;
          }
        }
        boolean _isEnemyDetected = data.isEnemyDetected();
        if (_isEnemyDetected) {
          SensorSample _sample_1 = it.sample();
          double _enemyDistanceInCentimeter = _sample_1.getEnemyDistanceInCentimeter();
          InputOutput.<Double>println(Double.valueOf(_enemyDistanceInCentimeter));
          double _enemyAngleInDegrees = data.getEnemyAngleInDegrees();
          double _minus = (-_enemyAngleInDegrees);
          it.rotate(_minus);
          it.forward(40);
          it.scoop(180);
          IMotor _scoopMotor = it.getScoopMotor();
          _scoopMotor.waitComplete();
          it.scoop((-180));
          it.stop();
        }
      }
    }
    it.stop();
  }
}
