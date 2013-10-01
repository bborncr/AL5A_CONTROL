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

float X = 85.0;
float Y = 85.0;
int Z = 90;
int G = 90;
int WR = 90;
float WA = 0;

float tmpx = 85.0;
float tmpy = 85.0;
int tmpz = 90;
int tmpg = 90;
int tmpwr = 90;
float tmpwa = 0;

boolean sval=false;

GImageToggleButton btnToggle0;

public void setup(){
  size(750, 700, JAVA2D);
  createGUI();
  btnToggle0 = new GImageToggleButton(this, 133, 469);
  leap = new LeapMotion(this);
  crciberneticalogo = loadImage("CRCibernetica509x81.png");
  String portName = "";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  dropList1.setItems(Serial.list(), 0);
}

public void draw(){
  background(255);
  image(crciberneticalogo,414,636,305,48.5);
  int fps = leap.getFrameRate();
  
  // HANDS
 // for(Hand hand : leap.getHands()){
   ArrayList hands = leap.getHands();
   if (!hands.isEmpty()){
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
    //float   hand1_yaw         = hand1.getYaw();
    float   hand1_time        = hand1.getTimeVisible();
    //float   hand2_time        = hand2.getTimeVisible();
    //PVector sphere_position  = hand.getSpherePosition();
    //float   sphere_radius    = hand.getSphereRadius();
    if(hand1_time>1.0){
     println("x: " +hand1_stabilized.x+" y: "+hand1_stabilized.y+" z:"+hand1_stabilized.z);
     float transHand1PosZ = map(hand1_stabilized.x,150,450,50,130);
     slider1.setValue(transHand1PosZ);
     float transHand1PosY = map(hand1_stabilized.y,550,300,20,130);
     slider2d1.setValueY(transHand1PosY);
     float transHand1PosX = map(hand1_position.z,30,55,20,175);
     slider2d1.setValueX(transHand1PosX);
    //println("HandYaw " +hand_yaw+" OUTPUT: "+transHandYaw+ " Time: "+hand_time);
    float transHand1Roll = map(hand1_roll,30,-30,45,-80);
    //println("HandRoll " +hand_roll+" OUTPUT: "+transHandRoll);
     slider6.setValue(transHand1Roll);
   }}
}

/* arm positioning routine utilizing inverse kinematics */
/* z is base angle, y vertical distance from base, x is hortizontal distance.*/
int Arm(float x, float y, float z, int g, float wa, int wr)
{
  float M = sqrt((y*y)+(x*x));
  if(M <= 0)
    return 1;
  float A1 = atan(y/x);
  float A2 = acos((A*A-B*B+M*M)/((A*2)*M));
  float Elbow = acos((A*A+B*B-M*M)/((A*2)*B));
  float Shoulder = A1 + A2;
  Elbow = Elbow * rtod;
  Shoulder = Shoulder * rtod;
  while((int)Elbow <= 0 || (int)Shoulder <= 0)
    return 1;
  float Wris = abs(wa - Elbow - Shoulder) - 90;
  slider2.setValue(Shoulder);
  slider3.setValue(180-Elbow);
  slider4.setValue(180-Wris);
  /*Elb.write(180 - Elbow);
  Shldr.write(Shoulder);
  Wrist.write(180 - Wris);
  Base.write(z);
  WristR.write(wr);
  Gripper.write(g);*/
  Y = tmpy;
  X = tmpx;
  Z = tmpz;
  WA = tmpwa;
  G = tmpg;
  WR = tmpwr;
  return 0;
}

// Event handler for image toggle buttons
public void handleToggleButtonEvents(GImageToggleButton button, GEvent event) { 
  //println(button + "   State: " + button.stateValue());
  slider5.setValue(button.stateValue()*150+10);
  
}
void keyPressed() {
  if(keyCode==32){
    sval=!sval;
    int stateVal=int(sval);
    btnToggle0.stateValue(stateVal);
    slider5.setValue(btnToggle0.stateValue()*150+10);
  }
}

