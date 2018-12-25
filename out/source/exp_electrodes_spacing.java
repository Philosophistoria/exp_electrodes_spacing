import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class exp_electrodes_spacing extends PApplet {

/** Program for the experiment of electrodes' spacing
 *  
 *  Inherited from a code by Tom Igoe. 
 *  \author  Akifumi Takahashi
 */





Serial myPort;      // The serial port
int whichKey = -1;  // Variable to hold keystoke values
int inByte = -1;    // Incoming serial data

public void setup() {
  
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);

  // List all the available serial ports:
  printArray(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // In Windows, this usually opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 921600);
}

public void draw() {
  background(0);
  text("Last Received: " + inByte, 10, 130);
  text("Last Sent: " + whichKey, 10, 100);
}

public void serialEvent(Serial myPort) {
  inByte = myPort.read();
}

public void keyPressed() {
  // Send the keystroke out:
  myPort.write(key);
  whichKey = key;
}
  public void settings() {  size(400, 300); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "exp_electrodes_spacing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
