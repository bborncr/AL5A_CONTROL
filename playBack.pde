void updatePlayBack() {
  long currentMillis = millis();
  if (PLAYBACK&&(currentMillis - previousMillis > interval)) {
    previousMillis = currentMillis;
    table = loadTable(selected_file, "header");
    println(table.getRowCount() + " total rows in table"); 
      TableRow row = table.getRow(playback_count);
      float x = row.getFloat("x");
      float y = row.getFloat("y");
      float z = row.getFloat("z");
      int g = row.getInt("g");
      float wa = row.getFloat("wa");
      int wr = row.getInt("wr");
      ArmPlayBack(x,y,z,g,wa,wr);
      println(x + "," + y + "," + z + "," + g + "," + wa + "," + wr);
      playback_count++;
      if (playback_count>=table.getRowCount()){
        playback_count = 0;
        PLAYBACK=false;
        println("Playback finished...");
      }
  }
}

