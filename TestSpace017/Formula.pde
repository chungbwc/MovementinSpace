// Sine ane cosine formulae for each node.

public class Formula {
  final int COUNT = 200; // number of vertices
  private int num_parms;
  private float step;
  private PVector pos;
  private PVector lst;
  private float [] pm;
  private Autoscale pScale;
  private color col;
  private boolean visible;
  private ArrayList<PVector> points;

  public Formula(color c) {
    num_parms = cf.PARMS;
    step = 0.0;
    pos = new PVector(0, 0, 0);
    lst = new PVector(0, 0, 0);
    pm = new float[num_parms];
    pScale = new Autoscale(-1, 1);
    visible = true;
    col = c;
    points = new ArrayList<PVector>();
  }

  public void stepFrame() {
    lst.x = pos.x;
    lst.y = pos.y;
    lst.z = pos.z;
    float tx = pm[0]*cos(radians(step*pm[1])) + pm[2]*sin(radians(step)+pm[3]);
    float ty = pm[4]*sin(radians(step*pm[5])) + pm[6]*cos(radians(step)+pm[7]);
    float tz = pm[8]*cos(radians(step*pm[9]))*sin(radians(step*pm[10])+pm[11]);
    //    float tz = pm[8]*cos(radians(step*pm[9])) + pm[10]*sin(radians(step)+pm[11]);
    pos = pScale.update(new PVector(tx, ty, tz));
    step+=1;
    points.add(pos);
    if (points.size() > COUNT) {
      points.remove(0);
    }
  }

  public void update(float [] p) {
    if (p.length != num_parms) 
      return;
    for (int i=0; i<num_parms; i++) {
      pm[i] = p[i];
    }
  }

  public PVector getPos() {
    return pos;
  }

  public float [] getParms() {
    return pm;
  }

  public void show(boolean v) {
    visible = v;
  }

  public void display(PGraphics p, PVector f, PVector o) {
    if (!visible) 
      return;

    p.pushStyle();
    p.noStroke();
    p.fill(col);

    float widthScale = 2.0;
    p.beginShape(QUAD_STRIP);
    for (int i=0; i<points.size()-1; i+=1) {
      PVector p1 = points.get(i);
      PVector p2 = points.get(i+1);
      PVector p3 = p2.cross(p1).add(p1);
      PVector p4 = PVector.sub(p3, p1);
      float ds = p1.dist(p2);
      ds = constrain(ds, 0.01, 0.04);
      // ds = 0.05 - constrain(ds, 0.01, 0.04);
      p4.setMag(ds*widthScale);
      p3 = p4.add(p1);
      p.vertex(p3.x*f.x+o.x, p3.y*f.y+o.y, p3.z*f.z+o.z);
      p.vertex(p1.x*f.x+o.x, p1.y*f.y+o.y, p1.z*f.z+o.z);
    }
    p.endShape();
    p.popStyle();
  }
}
