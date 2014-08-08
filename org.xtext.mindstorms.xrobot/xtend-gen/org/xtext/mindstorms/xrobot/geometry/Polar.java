package org.xtext.mindstorms.xrobot.geometry;

import org.eclipse.xtend.lib.Data;
import org.eclipse.xtext.xbase.lib.util.ToStringHelper;

@Data
@SuppressWarnings("all")
public class Polar {
  private final float _angle;
  
  public float getAngle() {
    return this._angle;
  }
  
  private final float _distance;
  
  public float getDistance() {
    return this._distance;
  }
  
  public Polar(final float angle, final float distance) {
    super();
    this._angle = angle;
    this._distance = distance;
  }
  
  @Override
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + Float.floatToIntBits(this._angle);
    result = prime * result + Float.floatToIntBits(this._distance);
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
    Polar other = (Polar) obj;
    if (Float.floatToIntBits(other._angle) != Float.floatToIntBits(this._angle))
      return false;
    if (Float.floatToIntBits(other._distance) != Float.floatToIntBits(this._distance))
      return false;
    return true;
  }
  
  @Override
  public String toString() {
    String result = new ToStringHelper().toString(this);
    return result;
  }
}
