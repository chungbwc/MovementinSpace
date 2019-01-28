// No proper UI has been done yet.
import websockets.*;
import java.util.TimerTask;
import java.util.Timer;
import java.util.Date;

final int SCW = 1360, SCH = 768; // screen width and height
final int XOFF = (SCW - SCH)/2;  // offset to compensate the square display
WebsocketServer ws1, ws2;
int max_lines;
int num_parms;
Playground [] play;
PVector factor;
PVector offset;
PVector imSize;
PGraphics circle;
PGraphics [] tmp;
float [][] parms;
Config cf; // global definitions

public void settings() {
  //size(SCW*4, SCH, P3D);   // run in a window
  fullScreen(P3D, SPAN);     // uncomment for fullscreen
}

public void setup() {
  surface.setSize(SCW*4, SCH); // uncomment for fullscreen
  surface.setLocation(0, 0);   // uncomment for fullscreen
  background(0);
  frameRate(60);
  cf = new Config();
  max_lines = cf.MAX_LINES;
  num_parms = cf.PARMS;
  factor = new PVector(250, 250, 150);
  offset = new PVector(0, 0, 0);
  imSize = new PVector(SCH, SCH);

  parms = new float[max_lines][num_parms];
  for (int i=0; i<max_lines; i++) {
    parms[i] = new float[num_parms];
    for (int j=0; j<num_parms; j++) {
      //      parms[i][j] = random(-1, 1);
      parms[i][j] = 0;
    }
  }
  play = new Playground[4];
  for (int i=0; i<play.length; i++) {
    play[i] = new Playground(imSize, factor, offset, parms);
    play[i].changeView(i);
  }

  circle = createGraphics((int)imSize.x, (int)imSize.y);
  circle.beginDraw();
  circle.noStroke();
  circle.fill(0);
  circle.rect(0, 0, circle.width, circle.height);
  circle.fill(255);
  circle.ellipse(circle.width/2, circle.height/2, 
    circle.width, circle.height);
  circle.endDraw();

  tmp = new PGraphics[4];
  for (int i=0; i<play.length; i++) {
    play[i].play();
    tmp[i] = createGraphics((int)imSize.x, (int)imSize.y, P3D);
    tmp[i].beginDraw();
    tmp[i].background(0);
    tmp[i].endDraw();
  }
  ws1 = new WebsocketServer(this, 8888, "/space");
  ws2 = new WebsocketServer(this, 7777, "/cable");

  TimerTask task = new TimerTask() {
    @Override
      public void run() {
      sendClock();
    }
  };
  Timer timer = new Timer();
  timer.scheduleAtFixedRate(task, 0, cf.CLOCK);
  noCursor();
}

public void draw() {
  //clearScreen();
  background(0);
  for (Playground p : play) {
    p.play();
  }

  for (int i=0; i<tmp.length; i++) {
    tmp[i].beginDraw();
    tmp[i].background(0);
    tmp[i].image(play[i].getCanvas(), 0, 0);
    tmp[i].mask(circle);
    tmp[i].endDraw();
  }

  image(tmp[1], XOFF, 0);
  image(tmp[0], SCW+XOFF, 0);
  image(tmp[2], SCW*2+XOFF, 0);
  image(tmp[3], SCW*3+XOFF, 0);
}

public void webSocketServerEvent(String s) {
  JSONObject json = parseJSONObject(s);
  decodeParms(json);
}

private void decodeParms(JSONObject j) {
  String cmd = j.getString("command");
  if (cmd.equals("sliders")) {
    float [] pm = new float[num_parms];
    int id = j.getInt("id");
    for (int i=0; i<pm.length; i++) {
      pm[i] = j.getFloat("p" + str(i));
    }
    //    println(j.toString());
    for (Playground p : play) {
      p.changeParms(id, pm);
    }
  } else if (cmd.equals("connect")) {
    int cord_id = j.getInt("cord_id");
    int cord = cordToId(j.getString("cord"));
    int sock_id = j.getInt("socket_id");
    int sock = sockToId(j.getString("socket"));
    //    println("Connect " + cord_id + ", " + cord + ", " + sock_id + ", " + sock);
    // println(j.toString());
    Plug plug = new Plug();
    for (Playground p : play) {
      plug = p.connect(sock_id, sock, cord_id, cord);
    }
    JSONObject json = new JSONObject();
    json.setString("command", "turnoff");
    json.setInt("id", plug.getId());
    json.setInt("slider", plug.getCable());
    ws1.sendMessage(json.toString());
  } else if (cmd.equals("disconnect")) {
    int cord_id = j.getInt("cord_id");
    int cord = cordToId(j.getString("cord"));
    //    println(j.toString());
    Plug plug = new Plug();
    for (Playground p : play) {
      // println("Disconnect " + cord_id + ", " + cord);
      plug = p.disconnect(cord_id, cord); // need to fix
    }
    int id = plug.getId();
    int cb = plug.getCable();
    if (id != -1 && cb != -1) {
      JSONObject json = new JSONObject();
      json.setString("command", "turnon");
      json.setInt("id", id);
      json.setInt("slider", cb);
      ws1.sendMessage(json.toString());
    }
  }
}

private int cordToId(String c) {
  String [] st = {"x", "y", "z"};
  int res = -1;
  for (int i=0; i<st.length; i++) {
    if (st[i].equals(c)) {
      res = i;
      break;
    }
  }
  return res;
}

private int sockToId(String s) {
  String [] st = {
    "x1", "x2", "x3", "x4", 
    "y1", "y2", "y3", "y4", 
    "z1", "z2", "z3", "z4"};
  int res = -1;
  for (int i=0; i<st.length; i++) {
    if (st[i].equals(s)) {
      res = i;
      break;
    }
  }
  return res;
}

public void keyPressed() {
  switch (keyCode) {
  case 32:
    background(0);
    for (Playground p : play) {
      p.switchLine();
    }
    break;
  default:
    break;
  }
}

private void sendClock() {
  Date date = new Date();
  JSONObject json = new JSONObject();
  json.setString("command", "clock");
  json.setString("timestamp", date.toString());
  ws1.sendMessage(json.toString());
  ws2.sendMessage(json.toString());
  println(json.toString());
}
