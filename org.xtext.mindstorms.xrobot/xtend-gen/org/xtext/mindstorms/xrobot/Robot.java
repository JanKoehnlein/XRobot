package org.xtext.mindstorms.xrobot;

import lejos.hardware.Brick;
import lejos.hardware.motor.NXTRegulatedMotor;
import lejos.hardware.port.Port;
import lejos.hardware.sensor.EV3ColorSensor;
import lejos.hardware.sensor.EV3IRSensor;
import lejos.hardware.sensor.SensorMode;
import lejos.robotics.navigation.DifferentialPilot;
import org.xtext.mindstorms.xrobot.IRobot;
import org.xtext.mindstorms.xrobot.geometry.Point;
import org.xtext.mindstorms.xrobot.geometry.Polar;

@SuppressWarnings("all")
public class Robot implements IRobot {
  private DifferentialPilot pilot;
  
  private EV3IRSensor irSensor;
  
  private EV3ColorSensor colorSensor;
  
  private Point position = new Point(0, 0);
  
  private double bearing;
  
  public Robot(final Brick brick) {
    Port _port = brick.getPort("B");
    NXTRegulatedMotor _nXTRegulatedMotor = new NXTRegulatedMotor(_port);
    Port _port_1 = brick.getPort("C");
    NXTRegulatedMotor _nXTRegulatedMotor_1 = new NXTRegulatedMotor(_port_1);
    DifferentialPilot _differentialPilot = new DifferentialPilot(43.2, 133.0, _nXTRegulatedMotor, _nXTRegulatedMotor_1);
    this.pilot = _differentialPilot;
    Port _port_2 = brick.getPort("S4");
    EV3IRSensor _eV3IRSensor = new EV3IRSensor(_port_2);
    this.irSensor = _eV3IRSensor;
    Port _port_3 = brick.getPort("S3");
    EV3ColorSensor _eV3ColorSensor = new EV3ColorSensor(_port_3);
    this.colorSensor = _eV3ColorSensor;
  }
  
  public Point getPosition() {
    return this.position;
  }
  
  public double getBearing() {
    return Math.toDegrees(this.bearing);
  }
  
  public void rotate(final double angle) {
    this.pilot.rotate(angle);
    double _bearing = this.bearing;
    double _radians = Math.toRadians(angle);
    bearing = (_bearing + _radians);
  }
  
  public void forward(final double distance) {
    this.pilot.travel(distance);
    double _cos = Math.cos(this.bearing);
    double _multiply = (_cos * distance);
    double _sin = Math.sin(this.bearing);
    double _multiply_1 = (_sin * distance);
    Point _point = new Point(_multiply, _multiply_1);
    Point _plus = this.position.operator_plus(_point);
    this.position = _plus;
  }
  
  public void backward(final double distance) {
    this.pilot.travel((-distance));
    double _cos = Math.cos(this.bearing);
    double _multiply = (_cos * distance);
    double _sin = Math.sin(this.bearing);
    double _multiply_1 = (_sin * distance);
    Point _point = new Point(_multiply, _multiply_1);
    Point _minus = this.position.operator_minus(_point);
    this.position = _minus;
  }
  
  public double measureDistance() {
    final float[] sample = new float[1];
    SensorMode _distanceMode = this.irSensor.getDistanceMode();
    _distanceMode.fetchSample(sample, 0);
    return sample[0];
  }
  
  public Polar measureEnemyBearing() {
    final float[] sample = new float[8];
    SensorMode _seekMode = this.irSensor.getSeekMode();
    _seekMode.fetchSample(sample, 0);
    {
      int i = 1;
      boolean _while = (i < 8);
      while (_while) {
        float _get = sample[i];
        boolean _lessThan = (_get < 255);
        if (_lessThan) {
          float _get_1 = sample[(i - 1)];
          float _get_2 = sample[i];
          return new Polar(_get_1, _get_2);
        }
        int _i = i;
        i = (_i + 2);
        _while = (i < 8);
      }
    }
    return null;
  }
  
  public double measureGroundColor() {
    final float[] sample = new float[1];
    SensorMode _redMode = this.colorSensor.getRedMode();
    _redMode.fetchSample(sample, 0);
    return sample[0];
  }
}
