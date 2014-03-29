void controlLamp(int lamp){
  int x = 255*lamp;
  myPort.clear();
  myPort.write("6,"+x+","+x+","+x+"\n");
  myPort.write("7,"+x+","+x+","+x+"\n");
  myPort.write("10,"+x+","+x+","+x+"\n");
  myPort.write("11,"+x+","+x+","+x+"\n");
}
