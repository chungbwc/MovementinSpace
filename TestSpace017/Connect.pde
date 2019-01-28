// Maintain information for 1 connection.

public class Connect {
  private int nodeid;
  private int xyz;

  public Connect(int n, int x) {
    nodeid = n;
    if (x >= 0 && x <=2) {
      xyz = x;
    } else {
      xyz = 0; // default to x-axis
    }
  }

  public int getNode() {
    return nodeid;
  }

  public int getOutput() {
    return xyz;
  }
}
