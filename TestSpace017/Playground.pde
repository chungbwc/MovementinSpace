// Main control class

public class Playground {
  private int max_lines;
  private int num_parms;
  private int options;

  private ArrayList<Formula> lines;
  private PVector factor;
  private PVector offset;
  private Connection conn;
  private ArrayList<float []> parms;
  private int idx;
  private color [] colors;
  private PGraphics p3;
  private float eyeDist;
  private int viewDir;

  public Playground(PVector s, PVector f, PVector o, float [][] r) {
    idx = 0;
    max_lines = cf.MAX_LINES;
    num_parms = cf.PARMS;
    options = cf.OPTIONS;
    colors = new color[max_lines];
    colors[0] = color(255, 0, 0, 200);
    colors[1] = color(0, 255, 0, 200);
    colors[2] = color(0, 100, 255, 200);
    colors[3] = color(220, 200, 200, 200);
    lines = new ArrayList<Formula>();
    parms = new ArrayList<float []>();
    factor = f;
    offset = new PVector(o.x, o.y, o.z);
    for (int i=0; i<max_lines; i++) {
      Formula t = new Formula(colors[i]);
      float [] p = new float[num_parms];
      for (int j=0; j<p.length; j++) {
        p[j] = r[i][j];
      }
      t.update(p);
      parms.add(p);
      lines.add(t);
    }
    conn = new Connection(max_lines);
    p3 = createGraphics((int)s.x, (int)s.y, P3D);
    p3.smooth(4);
    p3.beginDraw();
    p3.hint(DISABLE_DEPTH_TEST);
    p3.background(0);
    p3.endDraw();
    eyeDist = (p3.height/2.0) / tan(PI*30.0/180.0);
    viewDir = 0;
  }

  public void changeView(int v) {
    viewDir = v;
  }

  public void getParms() {
    for (int i=0; i<lines.size(); i++) {
      float [] p = lines.get(i).getParms();
      for (int j=0; j<p.length; j++) {
        parms.get(i)[j] = p[j];
      }
    }
  }

  public void play() {
    p3.beginDraw();
    p3.background(0);
    switch (viewDir) {
    case 0:
      p3.camera();
      break;
    case 1:
      p3.camera(p3.width/2+eyeDist, p3.height/2, 0, 
        p3.width/2, p3.height/2, 0, 0, 1, 0);
      break;
    case 2:
      p3.camera(p3.width/2, p3.height/2, -eyeDist, 
        p3.width/2, p3.height/2, 0, 0, 1, 0);
      break;
    case 3:
      p3.camera(p3.width/2-eyeDist, p3.height/2, 0, 
        p3.width/2, p3.height/2, 0, 0, 1, 0);
      break;
    }
    p3.lights();
    p3.pushMatrix();
    p3.translate(p3.width/2, p3.height/2, 0);

    for (int i=0; i<lines.size(); i++) {
      Connect [] c = conn.getConnect(i);
      float [] p = lines.get(i).getParms();

      for (int j=0; j<c.length; j++) {
        if (c[j] == null) 
          continue;

        int nodeid = c[j].getNode();
        int xy = c[j].getOutput();
        PVector pos = lines.get(nodeid).getPos();
        float val = (xy == 0) ? pos.x: pos.y;
        p[j] = val;
      }
      lines.get(i).update(p);
      lines.get(i).stepFrame();
      lines.get(i).display(p3, factor, offset);
    }
    p3.popMatrix();
    p3.endDraw();
  }

  public PGraphics getCanvas() {
    return p3;
  }

  public Plug connect(int n1, int p, int n2, int o) {
    Plug plug = new Plug();
    conn.connect(n1, p, n2, o);
    plug.update(n1, p);
    return plug;
  }

  public Plug disconnect(int n1, int p) {
    Plug plug = conn.remove(n1, p);
    return plug;
  }

  public void changeParms(int l, float [] p) {
    float [] pp = parms.get(l);
    for (int i=0; i<num_parms; i++) {
      pp[i] = p[i];
    }
    parms.set(l, pp);
    lines.get(l).update(pp);
  }

  public void switchLine() {
    if (idx < (options-1)) {
      for (int i=0; i<lines.size(); i++) {
        if (i == idx) 
          lines.get(i).show(true);
        else 
        lines.get(i).show(false);
      }
    } else {
      for (Formula f : lines) {
        f.show(true);
      }
    }
    idx++;
    idx %= options;
  }
}
