package org.xtext.mindstorms.xrobot.geometry;

import org.eclipse.xtend.lib.Data;
import org.eclipse.xtext.xbase.lib.util.ToStringHelper;

@Data
@SuppressWarnings("all")
public class Point {
  private final double _x;
  
  public double getX() {
    return this._x;
  }
  
  private final double _y;
  
  public double getY() {
    return this._y;
  }
  
  public Point operator_plus(final Point other) {
    double _x = other.getX();
    double _x_1 = this.getX();
    double _plus = (_x + _x_1);
    double _y = other.getY();
    double _y_1 = this.getY();
    double _plus_1 = (_y + _y_1);
    return new Point(_plus, _plus_1);
  }
  
  public Point operator_minus(final Point other) {
    double _x = this.getX();
    double _x_1 = other.getX();
    double _minus = (_x - _x_1);
    double _y = this.getY();
    double _y_1 = other.getY();
    double _minus_1 = (_y - _y_1);
    return new Point(_minus, _minus_1);
  }
  
  public Point operator_multiply(final double scale) {
    double _x = this.getX();
    double _multiply = (_x * scale);
    double _y = this.getY();
    double _multiply_1 = (_y * scale);
    return new Point(_multiply, _multiply_1);
  }
  
  public Point(final double x, final double y) {
    super();
    this._x = x;
    this._y = y;
  }
  
  @Override
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + (int) (Double.doubleToLongBits(this._x) ^ (Double.doubleToLongBits(this._x) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this._y) ^ (Double.doubleToLongBits(this._y) >>> 32));
    return result;
  }
  
  @Override
  public boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Point other = (Point) obj;
    if (Double.doubleToLongBits(other._x) != Double.doubleToLongBits(this._x))
      return false;
    if (Double.doubleToLongBits(other._y) != Double.doubleToLongBits(this._y))
      return false;
    return true;
  }
  
  @Override
  public String toString() {
    String result = new ToStringHelper().toString(this);
    return result;
  }
}
