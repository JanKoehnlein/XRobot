package org.xtext.mindstorms.xrobot.geometry;

import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public class Point {
  private final double x;
  
  private final double y;
  
  public Point operator_plus(final Point other) {
    return new Point((other.x + this.x), (other.y + this.y));
  }
  
  public Point operator_minus(final Point other) {
    return new Point((this.x - other.x), (this.y - other.y));
  }
  
  public Point operator_multiply(final double scale) {
    return new Point((this.x * scale), (this.y * scale));
  }
  
  public Point(final double x, final double y) {
    super();
    this.x = x;
    this.y = y;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + (int) (Double.doubleToLongBits(this.x) ^ (Double.doubleToLongBits(this.x) >>> 32));
    result = prime * result + (int) (Double.doubleToLongBits(this.y) ^ (Double.doubleToLongBits(this.y) >>> 32));
    return result;
  }
  
  @Override
  @Pure
  public boolean equals(final Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Point other = (Point) obj;
    if (Double.doubleToLongBits(other.x) != Double.doubleToLongBits(this.x))
      return false; 
    if (Double.doubleToLongBits(other.y) != Double.doubleToLongBits(this.y))
      return false; 
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("x", this.x);
    b.add("y", this.y);
    return b.toString();
  }
  
  @Pure
  public double getX() {
    return this.x;
  }
  
  @Pure
  public double getY() {
    return this.y;
  }
}
