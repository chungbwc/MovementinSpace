import websockets.*;
import controlP5.*;

final int PARMS = 12;
final int PLAYERS = 4;

ControlP5 cp5;
DropdownList idList1, idList2, idList3, idList4;
DropdownList cordList1, cordList2, sockList;
Button connect, disconnect;
int id, oid;
String msg;
Slider [] sliders;
float [][] parms;
WebsocketClient ws1, ws2;
CallbackListener cb1, cb2;

void settings() {
  size(960, 680);
}

void setup() {
  ws1 = new WebsocketClient(this, "ws://localhost:8888/space");
  ws2 = new WebsocketClient(this, "ws://localhost:7777/cable");
  msg = "";
  id = -1;
  oid = -1;

  parms = new float[PLAYERS][PARMS];
  for (int i=0; i<PLAYERS; i++) {
    for (int j=0; j<PARMS; j++) {
      parms[i][j] = 0.0;
    }
  }

  cp5 = new ControlP5(this);
  idList1 = cp5.addDropdownList("cord id 1")
    .setPosition(100, 100)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(4);

  cordList1 = cp5.addDropdownList("cord 1")
    .setPosition(200, 100)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(3);

  idList2 = cp5.addDropdownList("socket id")
    .setPosition(350, 100)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(4);

  sockList = cp5.addDropdownList("socket")
    .setPosition(450, 100)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(12);

  connect = cp5.addButton("connect")
    .setPosition(100, 220)
    .setHeight(30);

  idList3 = cp5.addDropdownList("cord id 2")
    .setPosition(100, 320)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(4);

  cordList2 = cp5.addDropdownList("cord 2")
    .setPosition(200, 320)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(3);

  disconnect = cp5.addButton("disconnect")
    .setPosition(100, 440)
    .setHeight(30);

  idList1.addItem("red", 0);
  idList1.addItem("green", 1);
  idList1.addItem("blue", 2);
  idList1.addItem("grey", 3);

  idList2.addItem("red", 0);
  idList2.addItem("green", 1);
  idList2.addItem("blue", 2);
  idList2.addItem("grey", 3);

  idList3.addItem("red", 0);
  idList3.addItem("green", 1);
  idList3.addItem("blue", 2);
  idList3.addItem("grey", 3);

  cordList1.addItem("x", 0);
  cordList1.addItem("y", 1);
  cordList1.addItem("z", 2);

  cordList2.addItem("x", 0);
  cordList2.addItem("y", 1);
  cordList2.addItem("z", 2);

  for (int i=0; i<4; i++) {
    sockList.addItem("x"+(i+1), i);
  }
  for (int i=0; i<4; i++) {
    sockList.addItem("y"+(i+1), i);
  }
  for (int i=0; i<4; i++) {
    sockList.addItem("z"+(i+1), i);
  }

  sliders = new Slider[PARMS];
  for (int i=0; i<sliders.length; i++) {
    sliders[i] = cp5.addSlider("p" + str(i))
      .setPosition(650, 100+i*30)
      .setSize(200, 20)
      .setRange(-1, 1)
      .setValue(0)
      .setColorCaptionLabel(color(100, 10, 10))
      .setId(i);
  }

  idList4 = cp5.addDropdownList("id")
    .setPosition(650, 500)
    .setItemHeight(30)
    .setBarHeight(30)
    .setId(4);

  idList4.addItem("red", 0);
  idList4.addItem("green", 1);
  idList4.addItem("blue", 2);
  idList4.addItem("grey", 3);

  cb1 = new CallbackListener() {
    public void controlEvent(CallbackEvent e) {
      if (e.getAction()==ControlP5.ACTION_BROADCAST) {
        prepareParms();
      }
    }
  };

  for (Slider s : sliders) {
    s.onChange(cb1);
  }

  idList4.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent e) {
      id = (int) e.getController().getValue();
      if (oid != id) {
        changePlayer();
        oid = id;
      }
    }
  }
  );
}

void draw() {
  background(0);
}

void controlEvent(ControlEvent e) {
  if (e.isController()) {
    String nm = e.getController().getName();
    int val = (int) e.getController().getValue();
    if (val != 1) 
      return;
    if (nm.equals("connect")) {
      JSONObject json = new JSONObject();
      json.setString("command", "connect");
      json.setInt("cord_id", (int)idList1.getValue());
      json.setString("cord", cordList1.getLabel());
      json.setInt("socket_id", (int)idList2.getValue());
      json.setString("socket", sockList.getLabel());
      ws2.sendMessage(json.toString());
    } else if (nm.equals("disconnect")) {
      JSONObject json = new JSONObject();
      json.setString("command", "disconnect");
      json.setInt("cord_id", (int)idList3.getValue());
      json.setString("cord", cordList2.getLabel());
      ws2.sendMessage(json.toString());
    }
  }
}

void prepareParms() {
  if (id == -1) 
    return;
  JSONObject json = new JSONObject();
  json.setString("command", "sliders");
  json.setInt("id", id);
  for (int i=0; i<sliders.length; i++) {
    parms[id][i] = sliders[i].getValue();
    json.setFloat(sliders[i].getLabel(), sliders[i].getValue());
  }
  //  println(json.toString());
  ws1.sendMessage(json.toString());
}

void changePlayer() {
  // println("change player now " + id);
  for (int i=0; i<PARMS; i++) {
    sliders[i].setBroadcast(false);
    sliders[i].setValue(parms[id][i]);
    sliders[i].setBroadcast(true);
  }
}

void webSocketEvent(String m) {
  println(m);
}
