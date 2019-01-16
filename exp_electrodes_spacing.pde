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
static final int FRAMERATE = 60;

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
int ph_skin = 0,
    ph_force= 0,
    ph_pain = 0,
    ph_comp = 0;

boolean ph_controllableF = false;

int condition[][];
int cond_ref;
int cond_cmp;


void setup() 
{
  condition = new int[3][3];
  //  Prepare a main Window
  //  size() cannot use variables
  size(16,9);
  //  resize with variables
  surface.setSize(WINDOW_X, WINDOW_Y);

  frameRate(FRAMERATE);

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
    //myPort.bufferUntil(lf);
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

  int fcmod = frameCount % (12 * FRAMERATE);
  //  small rest
  if (fcmod < 1 * FRAMERATE) {
    mygui.setStimulationOFF();
    //myPort.write('a');
  }
  //  stimulate
  else if (fcmod < 6 * FRAMERATE) {
    //  on reference condion
    if(mygui.getFlowStatus() != FlowState.COMPARING){
      mygui.setStimState(Left_Right.LEFT);
      //myPort.write('a');
    }
    //  on reference condion
    else {
      mygui.setStimState(Left_Right.LEFT);
      //myPort.write('a');
    }
  }
  //  small rest
  else if (fcmod < 7 * FRAMERATE) {
    mygui.setStimulationOFF();
    //myPort.write('a');
  }
  //  stimulate
  else if (fcmod < 12 * FRAMERATE) {
    //  on reference condion
    if(mygui.getFlowStatus() != FlowState.COMPARING){
      mygui.setStimState(Left_Right.LEFT);
      //myPort.write('a');
    }
    //  on comparison condion
    else {
      mygui.setStimState(Left_Right.RIGHT);
      //myPort.write('a');
    }
  }
  else  //shouldnt be called
    mygui.setStimulationOFF();
    //myPort.write('a');

  if (frameCount % FRAMERATE == 0){
    //myPort.write('a');
    //ph = (int)(myPort.readBytes(1)[0]);
    //ph = ph << 8 | (int)(myPort.readBytes(1)[0]);
  }
  

  mygui.updatePulseMonitor(frameCount, ph, pp, pw);
  mygui.setCurrentHGageValue((float)ph/4095f);
  mygui.update();
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
  switch (keyCode){
    case UP:
      switch(mygui.getFlowStatus()){
        case COMPARING:
          break;
        default:
          if(ph > 4095 - 50) ph = 4095;
          else ph += 50;
          break;        
      }
      break;
    case DOWN:
      switch(mygui.getFlowStatus()){
        case COMPARING:
          break;
        default:
          if (!ph_controllableF) break;
          if(ph < 50) ph = 0;
          else ph -= 50;
          break;
      }
      break;
    case LEFT:
      mygui.setCursor(Left_Right.LEFT);
      break;
    case RIGHT:
      mygui.setCursor(Left_Right.RIGHT);
      break;
    default :
      //println("no keyCode");
      break;	
  }
  switch (key){
    case ENTER:
      switch(mygui.getFlowStatus()){
        case OUT_OF_PROC:
          if (!mygui.getSaveButtonFlag()) 
            mygui.fireSaveButton();
          else if (!mygui.getStartButtonFlag()) 
            mygui.fireStartButton();
          if (mygui.getStartButtonFlag()) 
            if(mygui.getCompleteGageValue() < 1.0f) {
              mygui.setFlowState(FlowState.THRE_SKIN);
              ph = 0;
              frameCount = 0;
            }
            else{
              for (int[] itr : condition) for (int jtr : itr) fwriter.println(jtr);
              fwriter.flush();
              fwriter.close();
              println("ALL PROCESS HAVE DONE");
            }
          break;
        case THRE_SKIN:
          ph_skin = ph;
          mygui.setFlowState(FlowState.THRE_FORCE);
          ph = 0;
          frameCount = 0;
          break;
        case THRE_FORCE:
          ph_force = ph;
          mygui.setFlowState(FlowState.THRE_PAIN);
          ph = 0;
          frameCount = 0;
          break;
        case THRE_PAIN:
          ph_pain = ph;
          mygui.setFlowState(FlowState.THRE_COMP);
          ph = 0;
          frameCount = 0;
          break;
        case THRE_COMP:
          ph_comp = ph;
          mygui.setFlowState(FlowState.COMPARING);
          ph = 0;
          frameCount = 0;
          break;
        case COMPARING:
          fwriter.println(
            ph_skin + "," + 
            ph_force+ "," +
            ph_pain + "," +
            ph_comp + "," +
            mygui.getCursor().getCaption()
          );
          fwriter.flush();
          mygui.setCompleteGageValue(mygui.getCompleteGageValue() + (float)(Math.ceil(1000f / 12f)) / 1000f);
          mygui.setFlowState(FlowState.OUT_OF_PROC);
          mygui.setCursor(Left_Right.LEFT);
          frameCount = 0;
          break;
      }
    break;
  }
}