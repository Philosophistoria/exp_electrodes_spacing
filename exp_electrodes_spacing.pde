/** Program for the experiment of electrodes' spacing
 *  
 *  Inherited from a code by Tom Igoe. 
 *  \author  Akifumi Takahashi
 */


import java.util.Arrays;
import processing.serial.*;
import controlP5.*;

Serial myPort;      // The serial port
int[] inByte;    // Incoming serial data
int whichKey = -1;  // Variable to hold keystoke values
int portindex = 0;

void setup() {
  size(800, 450);
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

void draw() {
  background(0);
  text("Last Received: " + inByte[0], 10, 130);
  text("Last Sent: " + whichKey, 10, 100);
}

void serialEvent(Serial myPort) {
  inByte[0] = myPort.read();
}

void keyPressed() {
  // Send the keystroke out:
  myPort.write(key);
  whichKey = key;
}
