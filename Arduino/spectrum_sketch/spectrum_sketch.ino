float val[7] = {0, 0, 0, 0, 0, 0, 0} ; //data receiver from serial port
int ledPins[7] = {2, 3, 4, 5, 6, 7, 8}; //pin digital io to 13
int refresh = 10; //in ms

//peaks variables.
int DECAY_TIME = 300; //decay for peaks in ms. Time to reach 0.
int PEAK_LIFE[7] = {0, 0, 0, 0, 0, 0, 0};
float PEAK[7] = {0, 0, 0, 0, 0, 0, 0}; // peak values when taking into account decay
float peakdecay[7] = {0, 0, 0, 0, 0, 0, 0}; //peak values when decaying

void setup() {
  for (int i = 0; i < 7; i++) {
    pinMode(ledPins[i], OUTPUT); //set to output
  }

  Serial.begin(9600);
}

void loop() {
  //read the array
  if (Serial.read() == 0xff) {
    for (int i = 0; i < 7; i++) {
      val[i] = Serial.read();
    }
  }
/*  
    for(int i=0; i<7; i++){
    val[i] = (float) random(0,900)/100; //read data// dummy data
        }
*/  
  
  for (int i = 0; i < 7; i++) {
    peakdecay[i] = decayVal(PEAK_LIFE[i], DECAY_TIME, PEAK[i]);
    if (val[i] > peakdecay[i]) {        //if the new value if larger than the decaying peak
      PEAK[i] = val[i]; // reset the peak intensity
      peakdecay[i] = val[i];
      PEAK_LIFE[i] = 0; //reset its lifetime to 0
    } else {
      PEAK_LIFE[i] += refresh;
    }
  }

/*  
    Serial.print(val[1]);
    Serial.print("\t");
    Serial.println(peakdecay[1]);
 */ 



  //test leds
  for (int i = 0; i < 7; i++) {
    if (peakdecay[i] > 20) {
      digitalWrite(ledPins[i], HIGH);
    } else {
      digitalWrite(ledPins[i], LOW);
    }
  }

  delay(refresh);
}

float decayVal(int lifetime, int decay_time, float origin_peak) {
  return origin_peak - (origin_peak / (float)decay_time * (float)lifetime);
}
