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

//  for GUI
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

//  for file handling
PrintWriter fwriter = (PrintWriter)null;

byte[] inByte;        // Incoming serial data
int inKey = -1;       // Variable to hold keystoke values

//  for deta stored
int ph = 0,
    pp = 2500, 
    pw = 200;

//User data
float completeRate;


void setup() {
  //  Prepare a main Window
  //  size() cannot use variables
  size(16,9);
  //  resize with variables
  surface.setSize(WINDOW_X, WINDOW_Y);

  frameRate(60);

  // create a font with the third font available to the system:
  //printArray(PFont.list());

  //  Prepare GUI feature
  mygui = new Exp_GUI(this, WINDOW_X, WINDOW_Y);

  //  get list of serial ports available
  portsAvailable = Serial.list();
  printArray(portsAvailable);
  mygui.addItems_ofPortList(portsAvailable);
  mygui.setSaveButtonListener(new ActionListener(){
    @Override
    public void actionPerformed(ActionEvent e){
      SaveButtonHandler();
    }
  });
  mygui.setStartButtonListener(new ActionListener(){
    @Override
    public void actionPerformed(ActionEvent e){
      StartButtonHandler();
    }
  });

  //  Prepare memory to store data sent thru Serial.
  inByte = new byte[256];
  Arrays.fill(inByte, (byte)-1);
}

//
//  Event handler
//
void SerialPort (int n)
{
    println("serial port: " + n);
}
void Handedness (int n)
{
    println("handedness: " + n);
}
void SaveButtonHandler ()
{
  println("save button was pressed");
  //  User's Initial Data
  String  pname, uname, uhand;
  int     ulen, ucir;
  //pname = mygui.getPortName();
  uname = mygui.getUserName();
  uhand = mygui.getHandedness();
  ulen  = mygui.getLength();
  ucir  = mygui.getCircumference();
  if (//pname.length() > 0 && 
      uhand.length() > 0 && 
      uname.length() > 0 && 
      ulen > -1 && 
      ucir > -1 
  ) {
    //  open a serial port 
    //myPort = new Serial(this, pname, 921600);
    //println("Sirial Port: " + pname);

    //  Open a file to save data
    if(createReader(uname + ".csv") == null)
      fwriter = createWriter(uname + ".csv");
    else
      for (int i = 0; fwriter == null; i++)
        if(createReader(uname + "(" + i + ")" + ".csv") == null)
          fwriter = createWriter(uname + "(" + i + ")" + ".csv");

    //  Write the initial data
    if (fwriter != null) {
      fwriter.println(
        uname + "," +
        uhand + "," +
        ulen  + "," +
        ucir  + ","
        );
      fwriter.flush();
    }
    mygui.setSaveButtonFlag(true);
  }
}

void StartButtonHandler()
{
  println("Start button was pressed");
  mygui.setStartButtonFlag(true);
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