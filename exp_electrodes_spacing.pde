/** Program for the experiment of electrodes' spacing
 *  
 *  Inherited from a code by Tom Igoe. 
 *  \author  Akifumi Takahashi
 */


import java.util.Arrays;
import processing.serial.*;
import controlP5.*;

//  GUI objects
ControlP5 cp5;
Slider currentS;
Chart waveIndicator;
ScrollableList portlist, handedness;
Textfield tbox_name, tbox_len, tbox_cir; 
Button button_save, button_start;
int expflow;
int stimopt;
int selection;

int clr_yet, clr_done;
boolean button_saveF = false;
boolean button_startF = false;

Serial myPort = (Serial)null;      // The serial port
String[] portsAvailable;
int portindex = -1;
byte[] inByte;    // Incoming serial data
int inKey = -1;  // Variable to hold keystoke values

int ph = 0,
    pp = 2500, 
    pw = 200;

//User data
int handindex = -1;

static final int 
  WINDOW_X = 800,
  WINDOW_Y = 450;
static final int
  UNIT_DIV20_X = WINDOW_X / 20,
  UNIT_DIV20_Y = WINDOW_Y / 20;

void setup() {
  //  16:9
  size(16,9);
  surface.setSize(WINDOW_X, WINDOW_Y);
  frameRate(50);
  // create a font with the third font available to the system:
  PFont myFont = createFont(PFont.list()[2], WINDOW_X / 100);
  textFont(myFont); 
  clr_yet = color(25, 100, 50);
  clr_done= color(50, 200, 100);

  //
  //  GUI Setup
  //
  cp5 = new ControlP5(this);
  //  for select serial port
  // List all the available serial ports:
  portsAvailable = Serial.list();
  portlist = cp5.addScrollableList("Serial_Port")
    .setPosition(UNIT_DIV20_X, UNIT_DIV20_Y)
    .setSize(UNIT_DIV20_X * 3 , UNIT_DIV20_Y * 3)
    .setBarHeight(UNIT_DIV20_Y)
    .setItemHeight(UNIT_DIV20_Y)
    .setFont(myFont)
    ;
  //  Check if any Serial Ports available
  //  and list them
  if (portsAvailable.length == 0) {
    println("No ports are available");
    exit();
  }
  else {
    println("The num of ports available: 1");
    printArray(portsAvailable);
    portlist .addItems(portsAvailable)
      .setType(ScrollableList.DROPDOWN) // currently supported DROPDOWN and LIST
      ;
  }

  //  User Data
  tbox_name = cp5.addTextfield("NAME")
    .setPosition(UNIT_DIV20_X * 5, UNIT_DIV20_Y)
    .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
    .setFont(myFont)
    ;
  handedness = cp5.addScrollableList("Handedness")
    .setPosition(UNIT_DIV20_X * 8, UNIT_DIV20_Y)
    .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y * 3)
    .setBarHeight(UNIT_DIV20_Y)
    .setItemHeight(UNIT_DIV20_Y)
    .addItems(Arrays.asList("Left", "Right"))
    .setType(ScrollableList.DROPDOWN) // currently supported DROPDOWN and LIST
    .setFont(myFont)
    ;
  tbox_len = cp5.addTextfield("Length")
    .setPosition(UNIT_DIV20_X * 11, UNIT_DIV20_Y)
    .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
    .setFont(myFont)
    ;
  tbox_cir = cp5.addTextfield("Circumference")
    .setPosition(UNIT_DIV20_X * 14, UNIT_DIV20_Y)
    .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
    .setFont(myFont)
    ;

  button_save = cp5.addButton("save")
    .setValue(0)
    .setPosition(UNIT_DIV20_X * 17, UNIT_DIV20_Y)
    .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
    .setColorBackground(clr_yet)
    .setFont(myFont)
    ;
  button_start = cp5.addButton("start")
    .setValue(0)
    .setPosition(UNIT_DIV20_X * 17, UNIT_DIV20_Y * 5)
    .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
    .setColorBackground(clr_yet)
    .setFont(myFont)
    ;

  //  for indicating amount of current
  currentS = cp5.addSlider("current")
    .setSize(UNIT_DIV20_X * 2, UNIT_DIV20_Y * 8)
    .setPosition(UNIT_DIV20_X, UNIT_DIV20_Y * 7)
    .setRange(0,4095)
    .setValue(2000)
    .showTickMarks(true)
    .setColorTickMark(clr_done)
    //.setNumberOfTickMarks(5)
    .setHandleSize(UNIT_DIV20_X / 80)
    .setSliderMode(Slider.FIX)
    .setColorCaptionLabel(color(100,100,100))
    .setColorBackground(0)
    .setFont(myFont)
    ;
  currentS.getValueLabel().setVisible(false);
  //  for indicationg wave form
  waveIndicator = cp5.addChart("dataflow")
    .setSize(UNIT_DIV20_X * 6, UNIT_DIV20_Y * 8)
    .setPosition(UNIT_DIV20_X * 4, UNIT_DIV20_Y * 7)
    .setRange(-10, 10)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(100))
    .setColorBackground(0)
    ;
  waveIndicator.addDataSet("incoming");
  waveIndicator.setData("incoming", new float[300]);


  //  Prepare memory to store data sent thru Serial.
  inByte = new byte[256];
  Arrays.fill(inByte, (byte)-1);

  

}

void draw() {
  background(0);
  text("Last Received: " + inByte[0], 10, 130);
  text("Last Sent: " + inKey, 10, 100);
  
  // unshift: add data from left to right (first in)
  //myChart.unshift("incoming", (sin(frameCount*0.1)*20));
  
  // push: add data from right to left (last in)
  //  In the case to show 6 period when pp = 2500 [us], buffer size = 300
  //  size of time window = 15000 [us]
  //  one frame = 50 [us]
  if((frameCount % (pp / 50)) < ((pp - pw) / 50))
    waveIndicator.push("incoming", 0);
  else
    waveIndicator.push("incoming", 10 * (float)ph / 4095f);
  
  currentS.setValue(ph);
  toggle_flow ((frameCount / 50) % 4);
  toggle_selection(selection);
  toggle_stimopt ((frameCount / 50) % 2);
}

String[] flowCapion = {
  "Cutaneous Thre.      (Reference)",
  "Proprioceptive Thre. (Reference)",
  "Pain Thre.           (Reference)",
  "Cutaneous Thre.      (Comparison)"
  };
void toggle_flow(int arg_val) {
  int cunit;

  for (int i = 0; i < 4; i++){
    cunit = 20 + 80 * ((4 - i + arg_val) % 4 == 0 ? 1 : 0);
    pushMatrix();
    noStroke();
    fill(cunit, cunit * 2, cunit);
    translate(UNIT_DIV20_X * 11, UNIT_DIV20_Y * (8 + 2 * i));
    ellipse(0, 0, UNIT_DIV20_Y, UNIT_DIV20_Y);
    popMatrix();

    pushMatrix();
    fill(cunit * 2);
    translate(UNIT_DIV20_X * 12, UNIT_DIV20_Y * (8 + 2 * i));
    text(flowCapion[i], 0, 0);
    popMatrix();
  }
}

void toggle_selection (int arg_val) {
  int cunit;
  for (int i = 0; i < 2; i++){
    cunit = 20 + 80 * ((2 - i + arg_val) % 2 == 0 ? 1 : 0);
    pushMatrix();
    noStroke();
    fill(cunit, cunit * 2, cunit * 2);
    translate(UNIT_DIV20_X * (1 + 10 * i), UNIT_DIV20_Y * 16);
    rect(0,0,UNIT_DIV20_X * 8.5, UNIT_DIV20_Y * 3, 5);
    popMatrix();
  }
}

void toggle_stimopt (int arg_val) {
  int cunit;
  for (int i = 0; i < 2; i++){
    cunit = 20 + 80 * ((2 - i + arg_val) % 2 == 0 ? 1 : 0);
    pushMatrix();
    stroke(0, 0, cunit);
    fill(cunit/10, cunit * 2 / 3, cunit * 2);
    translate(UNIT_DIV20_X * (1 + 10 * i), UNIT_DIV20_Y * 16);
    rect(UNIT_DIV20_X, UNIT_DIV20_Y / 2 ,UNIT_DIV20_X * 6.5, UNIT_DIV20_Y * 2);
    popMatrix();
  }
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

//  GUI
void Serial_Port (int n) {
  portindex = n;
  println("serial port: " + n);
}
void Handedness (int n) {
  handindex = n;
  println("handedness: " + n);
}

void save (int arg_val) {
  if (portindex >= 0 && handindex >= 0 && tbox_name.getIndex() > 0 && tbox_len.getIndex() > 0 && tbox_cir.getIndex() > 0){
    myPort = new Serial(this, portsAvailable[portindex], 921600);
    println(tbox_name.getText() + "," + tbox_len.getText() + "," + tbox_cir.getText());
    button_save.setColorBackground(clr_done);
    button_saveF = true;
  }
}

void start(int arg_val) {
  if (button_saveF) {
    button_start.setColorBackground(clr_done);
    button_startF = true;
  }
}