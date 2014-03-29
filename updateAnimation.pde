void updateAnimation() {
  long currentMillis = millis();
  if (RECORD&&(currentMillis - previousMillis > interval)) {
    previousMillis = currentMillis;
    saveCoordinates();
  }
}
