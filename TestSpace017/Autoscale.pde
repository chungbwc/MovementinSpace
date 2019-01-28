// Autoscale the output to the range of -1 to 1.
public class Autoscale {
  private float minValue, maxValue;
  private float minX, minY, minZ, maxX, maxY, maxZ;
  private float dist;

  public Autoscale(float mn, float mx) {
    minValue = mn;
    maxValue = mx;
    dist = maxValue - minValue;
    minX = Float.MAX_VALUE;
    minY = Float.MAX_VALUE;
    minZ = Float.MAX_VALUE;
    maxX = Float.MIN_VALUE;
    maxY = Float.MIN_VALUE;
    maxZ = Float.MIN_VALUE;
  }

  public PVector update(PVector p) {
    if (p.x < minX) {
      minX = p.x;
    } else if (p.x > maxX) {
      maxX = p.x;
    }
    if (p.y < minY) {
      minY = p.y;
    } else if (p.y > maxY) {
      maxY = p.y;
    }
    if (p.z < minZ) {
      minZ = p.z;
    } else if (p.z > maxZ) {
      maxZ = p.z;
    }
    PVector t = new PVector(0, 0, 0);
    //   float mx = max(maxX, maxY);
    //   float mn = min(minX, minY);
    t.x = (p.x - minX) * dist / (maxX - minX) + minValue;
    t.y = (p.y - minY) * dist / (maxY - minY) + minValue;
    t.z = (p.z - minZ) * dist / (maxZ - minZ) + minValue;
    return t;
  }
}
