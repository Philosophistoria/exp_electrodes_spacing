/** Program for the experiment of electrodes' spacing
 *  
 *  Inherited from a code by Tom Igoe. 
 *  \author  Akifumi Takahashi
 */


import java.util.Arrays;
import processing.serial.*;
import processing.core.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

Exp_GUI mygui;
int expflow;
int stimopt;
int selection;

static final int 
WINDOW_X = 800,
WINDOW_Y = 450;

//  for serial com
Serial myPort = (Serial)null;      // The serial port
String[] portsAvailable;
int portindex = -1;
byte[] inByte;        // Incoming serial data
int inKey = -1;       // Variable to hold keystoke values

int ph = 0,
    pp = 2500, 
    pw = 200;

void setup() {
  //  16:9
  size(16,9);
  surface.setSize(WINDOW_X, WINDOW_Y);
  frameRate(50);
  // create a font with the third font available to the system:
  printArray(PFont.list());

  mygui = new Exp_GUI(this, WINDOW_X, WINDOW_Y);
  mygui.setSaveButtonListener(new ActionListener(){
    @Override
    public void actionPerformed (ActionEvent e) {
      myPort = new Serial(exp_electrodes_spacing.this, portsAvailable[portindex], 921600);
      println("start button was pressed");
    }
  });
  mygui.setStartButtonListener(new ActionListener(){
    @Override
    public void actionPerformed (ActionEvent e) {
      println("start button was pressed");
    }
  });

  portsAvailable = Serial.list();
  //  Check if any Serial Ports available
  //  and list them
  if (portsAvailable.length == 0) {
      println("No ports are available, so that the program will be closed");
      //exit();
  }
  else {
      printArray(portsAvailable);
      mygui.addItems_ofPortList(portsAvailable);
  }

  //  Prepare memory to store data sent thru Serial.
  inByte = new byte[256];
  Arrays.fill(inByte, (byte)-1);
}

void draw() {
  background(0);
  text("Last Received: " + inByte[0], 10, 130);
  text("Last Sent: " + inKey, 10, 100);
  
  mygui.updatePulseMonitor(frameCount, ph, pp, pw);
  mygui.updateGageValue(mygui.currentHGage, (float)ph/4095f);
  expflow = (frameCount / 50) % 5;
  mygui.toggle_flow (expflow);
  //cursor_color_unit = 10 + (90 * (((frameCount / 50) % 5) == 4 ? 1 : 0));
  mygui.toggle_selection(selection, expflow == 4);
  mygui.toggle_stimopt ((frameCount / 50) % 2);
  //mygui.setGageValue(completeGage, ((frameCount / 50) % 100) / 100);
  mygui.updateGageValue(mygui.completeGage, (float)(int)((float)(frameCount % 1100) / 100f) / 10f);
  //println((float)(int)((float)(frameCount % 1001) / 100f) / 10f);
  //println((frameCount % 1001));

}

void serialEvent(Serial myPort) {
  inByte = myPort.readBytes(256);
}

void keyPressed() {
  if(myPort != (Serial)null){
    // Send the keystroke out:
    myPort.write(key);
    inKey = key;
  }
  if(keyCode == UP) {
    if(ph > 4095 - 50) ph = 4095;
    else ph += 50;
  }
  else if (keyCode == DOWN) {
    if(ph < 50) ph = 0;
    else ph -= 50;
  }
  else if (keyCode == LEFT) {
    selection = 0;
  }
  else if (keyCode == RIGHT) {
    selection = 1;
  }
}