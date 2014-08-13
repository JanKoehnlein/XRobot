package org.xtext.mindstorms.xrobot;

import lejos.hardware.Brick;
import lejos.hardware.Key;
import lejos.hardware.motor.NXTRegulatedMotor;
import lejos.hardware.port.Port;
import lejos.hardware.sensor.EV3ColorSensor;
import lejos.hardware.sensor.EV3IRSensor;
import lejos.hardware.sensor.EV3TouchSensor;
import lejos.hardware.sensor.SensorMode;
import lejos.robotics.navigation.DifferentialPilot;
import org.xtext.mindstorms.xrobot.IRobot;
import org.xtext.mindstorms.xrobot.geometry.Polar;

@SuppressWarnings("all")
public class Robot implements IRobot {
  private DifferentialPilot pilot;
  
  private NXTRegulatedMotor weaponMotor;
  
  private EV3IRSensor irSensor;
  
  private EV3ColorSensor colorSensor;
  
  private EV3TouchSensor touchSensor;
  
  private Key escapeKey;
  
  public Robot(final Brick brick) {
    Port _port = brick.getPort("B");
    NXTRegulatedMotor _nXTRegulatedMotor = new NXTRegulatedMotor(_port);
    Port _port_1 = brick.getPort("C");
    NXTRegulatedMotor _nXTRegulatedMotor_1 = new NXTRegulatedMotor(_port_1);
    DifferentialPilot _differentialPilot = new DifferentialPilot(4.32, 13.30, _nXTRegulatedMotor, _nXTRegulatedMotor_1);
    this.pilot = _differentialPilot;
    Port _port_2 = brick.getPort("A");
    NXTRegulatedMotor _nXTRegulatedMotor_2 = new NXTRegulatedMotor(_port_2);
    this.weaponMotor = _nXTRegulatedMotor_2;
    Port _port_3 = brick.getPort("S4");
    EV3IRSensor _eV3IRSensor = new EV3IRSensor(_port_3);
    this.irSensor = _eV3IRSensor;
    Port _port_4 = brick.getPort("S3");
    EV3ColorSensor _eV3ColorSensor = new EV3ColorSensor(_port_4);
    this.colorSensor = _eV3ColorSensor;
    Port _port_5 = brick.getPort("S1");
    EV3TouchSensor _eV3TouchSensor = new EV3TouchSensor(_port_5);
    this.touchSensor = _eV3TouchSensor;
    Key _key = brick.getKey("Escape");
    this.escapeKey = _key;
  }
  
  public boolean escapePressed() {
    return this.escapeKey.isDown();
  }
  
  public float measureDistance() {
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
        boolean _lessThan = (_get < 128);
        if (_lessThan) {
          float _get_1 = sample[(i - 1)];
          float _multiply = (3 * _get_1);
          float _get_2 = sample[i];
          float _multiply_1 = (2 * _get_2);
          return new Polar(_multiply, _multiply_1);
        }
        int _i = i;
        i = (_i + 2);
        _while = (i < 8);
      }
    }
    return Polar.INVALID;
  }
  
  public float measureGroundColor() {
    final float[] sample = new float[1];
    SensorMode _redMode = this.colorSensor.getRedMode();
    _redMode.fetchSample(sample, 0);
    return sample[0];
  }
  
  public float measureShieldContact() {
    final float[] sample = new float[1];
    SensorMode _touchMode = this.touchSensor.getTouchMode();
    _touchMode.fetchSample(sample, 0);
    return sample[0];
  }
  
  public void forward(final double distance) {
    this.pilot.travel(distance);
  }
  
  public void backward(final double distance) {
    this.pilot.travel((-distance));
  }
  
  public void setTravelSpeed(final double speed) {
    this.pilot.setTravelSpeed(speed);
  }
  
  public double getTravelSpeed() {
    return this.pilot.getTravelSpeed();
  }
  
  public double getMaxTravelSpeed() {
    return this.pilot.getMaxTravelSpeed();
  }
  
  public void rotate(final double angle) {
    this.pilot.rotate(angle);
  }
  
  public void setRotateSpeed(final double speed) {
    double _rotateSpeed = this.getRotateSpeed();
    this.pilot.setRotateSpeed(_rotateSpeed);
  }
  
  public double getRotateSpeed() {
    return this.pilot.getRotateSpeed();
  }
  
  public double getRotateMaxSpeed() {
    return this.pilot.getRotateMaxSpeed();
  }
  
  public void curveForward(final double radius, final double angle) {
    this.pilot.arc(radius, angle);
  }
  
  public void curveBackward(final double radius, final double angle) {
    this.pilot.arc(radius, (-angle));
  }
  
  public void curveTo(final Polar bearing) {
    float _angle = bearing.getAngle();
    final double angle = Math.toRadians(_angle);
    float _distance = bearing.getDistance();
    double _multiply = (0.5 * _distance);
    double _cos = Math.cos(((0.5 * Math.PI) - angle));
    final double radius = (_multiply * _cos);
    this.curveForward(radius, angle);
  }
  
  public void stop() {
    this.pilot.stop();
  }
  
  public void fireWeapon() {
    float _maxSpeed = this.weaponMotor.getMaxSpeed();
    this.weaponMotor.setSpeed(_maxSpeed);
    this.weaponMotor.rotateTo(140);
    this.weaponMotor.rotateTo(0);
  }
}
