void controlEyes(int eyes){
  int x = 255*eyes;
  myPort.clear();
  myPort.write("8,"+0+","+x+","+0+"\n");
  myPort.write("9,"+0+","+x+","+0+"\n");
}
