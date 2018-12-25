/** Program for the experiment of electrodes' spacing
 *  
 *  Inherited from a code by Tom Igoe. 
 *  \author  Akifumi Takahashi
 */


import java.util.Arrays;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Serial myPort;      // The serial port
int[] inByte;    // Incoming serial data
int inKey = -1;  // Variable to hold keystoke values
int portindex = 0;

static final int 
  WINDOW_X = 800,
  WINDOW_Y = 450;

void setup() {
  //  16:9
  size(16,9);
  surface.setSize(WINDOW_X, WINDOW_Y);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont); 

  cp5 = new ControlP5(this);
  cp5 .addSlider("current")
      .setSize(WINDOW_X / 3, 40)
      .setPosition(WINDOW_X / 2 - WINDOW_X / 6, WINDOW_Y / 2)
      .setRange(0,4095)
      //.setValue(2000)
      .setColorCaptionLabel(color(20,20,20))
      ;

  //  Prepare memory to store data sent thru Serial.
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
  text("Last Sent: " + inKey, 10, 100);
}

void serialEvent(Serial myPort) {
  inByte = myPort.readBytes(256);
}

void keyPressed() {
  // Send the keystroke out:
  myPort.write(key);
  inKey = key;
}
