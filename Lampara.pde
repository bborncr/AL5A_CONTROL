import de.voidplus.leapmotion.*;
// Need G4P library
import g4p_controls.*;
import processing.serial.*;

Serial myPort;
String s="";
PImage crciberneticalogo;
LeapMotion leap;

float A = 95.25; //millimeters
float B = 107.95;
float rtod = 57.295779;

boolean sval=false;

GImageToggleButton btnToggle0;
GImageToggleButton btnToggle1;

PrintWriter output;

String fileName;
Table table;
String selected_file;
int selectedfilecount=0;

boolean LEAPMOTION = false;
boolean PLAYBACK = false;
boolean RECORD = false;
int playback_count = 0;
long previousMillis = 0;
long previousBlinkMillis = 0;
long interval = 100;
boolean LAMP = false;

public void setup() {
  size(750, 700, JAVA2D);
  createGUI();
  btnToggle0 = new GImageToggleButton(this, 133, 469);
  btnToggle0.tag = "0";
  btnToggle1 = new GImageToggleButton(this, 183, 469);
  btnToggle1.tag = "1";
  leap = new LeapMotion(this);
  crciberneticalogo = loadImage("CRCibernetica509x81.png");
  String portName = "";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');

  dropList1.setItems(Serial.list(), 0);
  fileName = getDateTime();
  output = createWriter("data/" + "positions" + fileName + ".csv");
  output.println("x,y,z,g,wa,wr");
}

public void draw() {
  background(255);
  image(crciberneticalogo, 414, 636, 305, 48.5);

  if (LEAPMOTION) {
    updateLeapMotion();
  }
  updatePlayBack();
  updateAnimation();
  
 // updateBlink();
}

/* arm positioning routine utilizing inverse kinematics */
/* z is base angle, y vertical distance from base, x is horizontal distance.*/
int Arm(float x, float y, float z, int g, float wa, int wr)
{
  float M = sqrt((y*y)+(x*x));
  if (M <= 0)
    return 1;
  float A1 = atan(y/x);
  float A2 = acos((A*A-B*B+M*M)/((A*2)*M));
  float Elbow = acos((A*A+B*B-M*M)/((A*2)*B));
  float Shoulder = A1 + A2;
  Elbow = Elbow * rtod;
  Shoulder = Shoulder * rtod;
  while ( (int)Elbow <= 0 || (int)Shoulder <= 0)
    return 1;
  float Wris = abs(wa - Elbow - Shoulder) - 90;
  //slider1.setValue(z);
  slider2.setValue(Shoulder);
  slider3.setValue(180-Elbow);
  slider4.setValue(180-Wris);
  //slider5.setValue(g);
  /*Elb.write(180 - Elbow);
   Shldr.write(Shoulder);
   Wrist.write(180 - Wris);
   Base.write(z);
   WristR.write(wr);
   Gripper.write(g);*/
  return 0;
}

// Event handler for image toggle buttons
public void handleToggleButtonEvents(GImageToggleButton button, GEvent event) { 
  println(button + "   State: " + button.stateValue());
  if (button.tag=="1") {
    LEAPMOTION=boolean(button.stateValue());
  }
  if (button.tag=="0") {
    //toggle main light
    println("Light: " + button.stateValue());
    controlLamp(button.stateValue());
  }
}
void keyPressed() {
  if (keyCode==16){//right shift
    PLAYBACK = false;
    playback_count = 0;
    selected_file="normalstance.csv";
    PLAYBACK=true;
    controlEyes(0);
    controlLamp(1);
  }
   if (keyCode==47){// forward slash
    PLAYBACK = false;
    playback_count = 0;
    selectedfilecount=selectedfilecount+1;
    if(selectedfilecount>4){
      selectedfilecount=1;
    }
    selected_file=selectedfilecount+".csv";
    PLAYBACK=true;
    controlEyes(1);
    controlLamp(0);
  }
  
  if (keyCode==32) {
    sval=!sval;
    int stateVal=int(sval);
    btnToggle0.stateValue(stateVal);
    controlLamp(stateVal);
  }
  if (keyCode==83) { // s to save coordinates to file
    println("Coordinates saved to file");
    float x = slider2d1.getValueXI();
    float y = slider2d1.getValueYI();
    float z = slider1.getValueI();
    int g = slider5.getValueI();
    float w = slider6.getValueI();
    output.println(x + "," + y + "," + z + "," + g + "," + w + "," + 90);
  }
  if (keyCode==88) {
    println("Close file"); //x to save and close file
    RECORD=false;
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    //exit(); // Stops the program
  }
  if (keyCode==80) {
    println("Playback"); //p for playback
    PLAYBACK = true;
  }
  if (keyCode==78) { 
    fileName = getDateTime();
    output = createWriter("data/" + "positions" + fileName + ".csv");
    output.println("x,y,z,g,wa,wr");
    println("New position file"); //n for new file
  }
  if (keyCode==79) {
    println("Open File for Playback"); //o for open file for playback
    selectInput("Select a file to playback:", "fileSelected");
  }
  if (keyCode==82) {
    println("Record"); //r for record
    RECORD = true;
  }
}

void updateLeapMotion() {
  int fps = leap.getFrameRate();
  // HANDS
  // for(Hand hand : leap.getHands()){
  ArrayList hands = leap.getHands();
  if (!hands.isEmpty()) {
    Hand hand1 = (Hand) hands.toArray()[0];
    //Hand hand2 = (Hand) hands.toArray()[1];

    //hand.draw();
    //int     hand_id          = hand.getId();
    PVector hand1_position    = hand1.getPosition();
    PVector hand1_stabilized  = hand1.getStabilizedPosition();
    //PVector hand_direction   = hand.getDirection();
    //PVector hand_dynamics    = hand.getDynamics();
    float   hand1_roll        = hand1.getRoll();
    //float   hand1_pitch       = hand1.getPitch();
    float   hand1_yaw         = hand1.getYaw();
    float   hand1_time        = hand1.getTimeVisible();
    //float   hand2_time        = hand2.getTimeVisible();
    //PVector sphere_position  = hand.getSpherePosition();
    //float   sphere_radius    = hand.getSphereRadius();
    if (hand1_time>1.0) {
      //println("x: " +hand1_stabilized.x+" y: "+hand1_stabilized.y+" z:"+hand1_stabilized.z);
      float transHand1PosZ = map(hand1_stabilized.x, 150, 450, 50, 130);
      slider1.setValue(transHand1PosZ);
      float transHand1PosY = map(hand1_stabilized.y, 550, 300, 20, 200);
      slider2d1.setValueY(transHand1PosY);
      float transHand1PosX = map(hand1_position.z, 30, 55, 20, 175);
      slider2d1.setValueX(transHand1PosX);
      float transHand1Roll = map(hand1_roll, 30, -30, 45, -80);
      //println("HandRoll " +hand_roll+" OUTPUT: "+transHandRoll);
      slider6.setValue(transHand1Roll);
      float transHand1Yaw = map(hand1_yaw, 0, 50, 50, 175);
      println("Yaw " +hand1_yaw+" OUTPUT: "+transHand1Yaw);
      slider5.setValue(transHand1Yaw);
    }
  }
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
    println("User selected " + selection.getAbsolutePath());
    selected_file = selection.getAbsolutePath();
  }
}

String getDateTime() {
  int d = day();  
  int m = month(); 
  int y = year();  
  int h = hour();
  int min = minute();
  String s = String.valueOf(y);
  s = s + String.valueOf(m);
  s = s + String.valueOf(d);
  s = s + String.valueOf(h);
  s = s + String.valueOf(min);
  return s;
}
int ArmPlayBack(float x, float y, float z, int g, float wa, int wr)
{
  float M = sqrt((y*y)+(x*x));
  if (M <= 0)
    return 1;
  float A1 = atan(y/x);
  float A2 = acos((A*A-B*B+M*M)/((A*2)*M));
  float Elbow = acos((A*A+B*B-M*M)/((A*2)*B));
  float Shoulder = A1 + A2;
  Elbow = Elbow * rtod;
  Shoulder = Shoulder * rtod;
  while ( (int)Elbow <= 0 || (int)Shoulder <= 0)
    return 1;
  float Wris = abs(wa - Elbow - Shoulder) - 90;
  slider1.setValue(z);
  slider2.setValue(Shoulder);
  slider3.setValue(180-Elbow);
  slider4.setValue(180-Wris);
  slider5.setValue(g);
  /*Elb.write(180 - Elbow);
   Shldr.write(Shoulder);
   Wrist.write(180 - Wris);
   Base.write(z);
   WristR.write(wr);
   Gripper.write(g);*/
  return 0;
}

void saveCoordinates() {
  float x = slider2d1.getValueXI();
  float y = slider2d1.getValueYI();
  float z = slider1.getValueI();
  int g = slider5.getValueI();
  float w = slider6.getValueI();
  output.println(x + "," + y + "," + z + "," + g + "," + w + "," + 90);
}

