import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Arrays; 
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
int[] inByte;    // Incoming serial data
int whichKey = -1;  // Variable to hold keystoke values
int portindex = 0;

public void setup() {
  
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont); 
  inByte = new int[256];
  Arrays.fill(inByte, -1);

  // List all the available serial ports:
  String[] portsAvailable = Serial.list();
  
  if (portsAvailable.length == 0) {
    println("No ports are available");
    exit();
  }
  else if (portsAvailable.length == 1) {
    println("The num of ports available: 1");
    printArray(portsAvailable);
    myPort = new Serial(this, portsAvailable[0], 921600);
  }
  else {
    println("The num of ports available: " + portsAvailable.length);
    println("Too many ports");
    exit();
  }

}

public void draw() {
  background(0);
  text("Last Received: " + inByte[0], 10, 130);
  text("Last Sent: " + whichKey, 10, 100);
}

public void serialEvent(Serial myPort) {
  inByte[0] = myPort.read();
}

public void keyPressed() {
  // Send the keystroke out:
  myPort.write(key);
  whichKey = key;
}
  public void settings() {  size(800, 450); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "exp_electrodes_spacing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
