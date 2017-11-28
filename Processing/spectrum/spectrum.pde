 import ddf.minim.analysis.*;
 import ddf.minim.*;
 import processing.serial.*;
 
 Serial port;
 Minim minim;
 AudioInput in;
 FFT fft;
 PFont p;

 int buffer_size = 1024; //sets FFT size (frequency resolution)
 float sample_rate = 44100;
 
 int spectrum_height = 380; // determines range of dB shown

 float[] freq_array = {0,0,0,0,0,0,0};
 float[] freq_height = {0,0,0,0,0,0,0};
 float max = 0;
 
 float dB_scale = 5.0; // px per dB
 float gain = 50; // in dB for all bands
 float[] fine_gain = {0,0,0,0,0,0,0};
 boolean CALIB = true; //wether or not to use calibrated gain
 float[] CALIB_GAIN = {50.0, 50.0, 56.0, 61.0, 64.0, 69.0, 75.0};
 
 void setup()
 {
   size(400,400);
   p = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on
   
   minim = new Minim(this);
   //port = new Serial(this,Serial.list()[0],9600); //initial serial comm. not used for now.
   
   in = minim.getLineIn(Minim.MONO,buffer_size,sample_rate);
   fft = new FFT(in.bufferSize(), in.sampleRate()); // create a FFT obj in the same time domain sas the line in sample buffer.
   fft.window(FFT.HAMMING);
   
   if (CALIB == true){
   fine_gain = CALIB_GAIN ;
   gain = 0 ;
   }
 }
 
 void draw()
 {

 // clear background
 background(0);
    
 // forward FFT on the samples in input buffer
 fft.forward(in.mix);
 
 //frequency band ranges
 freq_height[0] = fft.calcAvg((float) 20, (float) 53);
 freq_height[1] = fft.calcAvg((float) 54, (float) 144);
 freq_height[2] = fft.calcAvg((float) 145, (float) 386);
 freq_height[3] = fft.calcAvg((float) 387, (float) 1036);
 freq_height[4] = fft.calcAvg((float) 1037, (float) 2779);
 freq_height[5] = fft.calcAvg((float) 2780, (float) 7455);
 freq_height[6] = fft.calcAvg((float) 7456, (float) 20000);
 
 if (max(freq_height) > max){max = max(freq_height);}
 
 stroke(64,192,255);
 noFill();

for(int i = 0; i < 7; i++)  {
    float val = abs(dB_scale*(20*((float)Math.log10(freq_height[i]/max)) + (fine_gain[i] + gain)));     // draw the line for frequency band i using dB scale
   if (freq_height[i] < 0.01) {   val = 0;   }  // avoid log(0)
    rect(15 + (i * (spectrum_height)/7),spectrum_height,(400-20)/7,-val);
    freq_array[i] = val;
    text(val/dB_scale,15 + (i * (spectrum_height)/7),80);
  }

textFont(p,15);
fill(255);
text(finegain(fine_gain, gain),20,40);
text(str(max),20,60);


 //send to serial
/*
port.write(0xff);
for(i=0;i<7;i++){
 port.write((byte)freq_array[i]);
}
*/

 }

String finegain(float[] g, float glob){
return str(g[0] + glob) + " - " + str(g[1] + glob) + " - " + str(g[2] + glob) + " - " + str(g[3] + glob) +" - "+ str(g[4] + glob) + " - " + str(g[5] + glob) +" - "+ str(g[6] + glob);
}


void keyReleased()
{
  // +/- used to adjust gain on the fly
  if (key == '+' || key == '=') {
    gain = gain + 5.0;
  } else if (key == '-' || key == '_') {
    gain = gain - 5.0;
  } else if (key =='1') {
    fine_gain[0] += 1.0;
  } else if (key =='q') {
    fine_gain[0] -= 1.0;
  } else if (key =='2') {
    fine_gain[1] += 1.0;
  } else if (key =='w') {
    fine_gain[1] -= 1.0;
  } else if (key =='3') {
    fine_gain[2] += 1.0;
  } else if (key =='e') {
    fine_gain[2] -= 1.0;
  } else if (key =='4') {
    fine_gain[3] += 1.0;
  } else if (key =='r') {
    fine_gain[3] -= 1.0;
  } else if (key =='5') {
    fine_gain[4] += 1.0;
  } else if (key =='t') {
    fine_gain[4] -= 1.0;
  } else if (key =='6') {
    fine_gain[5] += 1.0;
  } else if (key =='y') {
    fine_gain[5] -= 1.0;
  } else if (key =='7') {
    fine_gain[6] += 1.0;
  } else if (key =='u') {
    fine_gain[6] -= 1.0;
  }
}

void stop()
{
in.close();
minim.stop();
super.stop();
}