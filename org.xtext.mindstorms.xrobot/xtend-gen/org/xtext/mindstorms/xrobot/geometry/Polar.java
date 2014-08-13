package org.xtext.mindstorms.xrobot.geometry;

import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.internal.c;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@Data
@SuppressWarnings("all")
public class Polar {
  public final static Polar INVALID = new Polar(0, Float.MAX_VALUE);
  
  /**
   * in degrees
   */
  private final float angle;
  
  /**
   * in cm. Sorry, Americans :-)
   */
  private final float distance;
  
  public boolean isValid() {
    return (!c.equal(this, Polar.INVALID));
  }
  
  public Polar(final float angle, final float distance) {
    super();
    this.angle = angle;
    this.distance = distance;
  }
  
  @Override
  @Pure
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + Float.floatToIntBits(this.angle);
    result = prime * result + Float.floatToIntBits(this.distance);
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
    Polar other = (Polar) obj;
    if (Float.floatToIntBits(other.angle) != Float.floatToIntBits(this.angle))
      return false; 
    if (Float.floatToIntBits(other.distance) != Float.floatToIntBits(this.distance))
      return false; 
    return true;
  }
  
  @Override
  @Pure
  public String toString() {
    ToStringBuilder b = new ToStringBuilder(this);
    b.add("angle", this.angle);
    b.add("distance", this.distance);
    return b.toString();
  }
  
  @Pure
  public float getAngle() {
    return this.angle;
  }
  
  @Pure
  public float getDistance() {
    return this.distance;
  }
}
