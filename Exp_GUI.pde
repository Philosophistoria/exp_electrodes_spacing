/** GUI class
 *  
 *  This class is one for implementing Graphical User Interface
 *  used when experiments.
 *
 *  \author Akifumi Takahashi
 */

import controlP5.*;
import processing.core.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

enum FlowState{
    OUT_OF_PROC (""), 
    THRE_SKIN   ("(Reference)  Cutaneous Thre."), 
    THRE_FORCE  ("(Reference)  Proprioceptive Thre."), 
    THRE_PAIN   ("(Reference)  Pain Thre."), 
    THRE_COMP   ("(Comparison) Cutaneous Thre."),
    COMPARING   ("Select one FORCE sens. is STRONGER");
    private String caption;
    private FlowState (String arg_s) {caption = arg_s;}
    public String getCaption() {return caption;}
};
enum Left_Right{ 
    LEFT    ("Reference condition"), 
    RIGHT   ("Comparison condition");
    private String caption;
    private  Left_Right (String arg_s) {caption = arg_s;}
    public String getCaption() {return caption;}
};

public class Exp_GUI implements ControlListener
{
    //  GUI objects
    ControlP5 cp5;
    class SmoothBarGage 
    {
        Slider slider;
        float buffer;
        float ratio;
        float speed;
        public SmoothBarGage (Slider s){ this(s, 0.4f); }
        public SmoothBarGage (Slider s, float arg_speed){
            slider = s;
            buffer = s.getMin();
            speed = arg_speed;
            ratio = 0;
        }
        public void setRatio(float arg_ratio){this.ratio = arg_ratio;}
        public float getRatio(){return this.ratio;}
        public void update()
        {
            this.buffer += this.speed * (this.ratio - this.buffer);
            if(abs(this.buffer - this.ratio) < 0.01) this.buffer = this.ratio;
            this.slider.setValue(
                this.slider.getMin() 
                + this.buffer * (this.slider.getMax() - this.slider.getMin())
            );
        }
    }
    private SmoothBarGage currentHGage;
    private SmoothBarGage completeGage;
    private Chart waveIndicator;
    private ScrollableList portlist, handedness;
    private Integer portindex = -1, handindex = -1;
    private Textfield tbox_name, tbox_len, tbox_cir; 
    private Button button_save, button_start;

    //  Window size unit
    private final int WINDOW_X;
    private final int WINDOW_Y;
    private final int UNIT_DIV20_X;
    private final int UNIT_DIV20_Y;
    
    //colors of button
    private int clr_button_yet;
    private int clr_button_done;
    private int clrunit;

    //Event Listner
    ActionListener saveButtonL;
    ActionListener startButtonL;

    //Flags 
    private boolean button_saveF = false;
    private boolean button_startF = false;

    //  Constants & Variable for controlling the cursor
    final float cursor_speed;
    class Left_Right_Cord 
    {
        PVector left, right;
        public Left_Right_Cord(PVector arg_left, PVector arg_right)
        {
            left = arg_left;
            right = arg_right;
        }
        public PVector getCord(Left_Right arg_lr)
        {
            if (arg_lr == Left_Right.LEFT) return left;
            else return right;
        }
    }
    final Left_Right_Cord SEL_CORD;
    PVector cursor_cord;

    //  GUI State variables
    private FlowState flowStatus;
    private Left_Right userCursor;
    private Left_Right stimState;
    private boolean stimulationF = false;

    public Exp_GUI (PApplet theParent, int arg_WINDOW_X, int arg_WINDOW_Y)
    {
        WINDOW_X = arg_WINDOW_X;
        WINDOW_Y = arg_WINDOW_Y;
        UNIT_DIV20_X = WINDOW_X / 20;
        UNIT_DIV20_Y = WINDOW_Y / 20;
        //
        //  GUI Setup
        //
        {
            cp5 = new ControlP5(theParent);
            cp5.addListener(this);
            //
            //  Font
            //
            //  Meiryo UI: 215
            PFont mainFont = createFont(PFont.list()[2], UNIT_DIV20_X / 20 * 5);
            PFont subFont = createFont(PFont.list()[2], UNIT_DIV20_X / 12 * 2);
            textFont(mainFont); 
            //
            //  Color
            //
            clr_button_yet = color(25, 100, 50);
            clr_button_done= color(50, 200, 100);
            clrunit = 100;
            //  for select serial port
            //  List all the available serial ports:
            portlist = cp5.addScrollableList("SerialPort")
                .setLabel("Serial Port")
                .setPosition(UNIT_DIV20_X, UNIT_DIV20_Y)
                .setSize(UNIT_DIV20_X * 3 , UNIT_DIV20_Y * 3)
                .setBarHeight(UNIT_DIV20_Y)
                .setItemHeight(UNIT_DIV20_Y)
                .setType(ScrollableList.DROPDOWN) // currently supported DROPDOWN and LIST
                .close()
                .setFont(subFont)
                ;
            portlist.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
            //  User Data boxes
            tbox_name = cp5.addTextfield("NAME")
                .setPosition(UNIT_DIV20_X * 5, UNIT_DIV20_Y)
                .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
                .setFont(subFont)
                ;
            handedness = cp5.addScrollableList("Handedness")
                .setPosition(UNIT_DIV20_X * 8, UNIT_DIV20_Y)
                .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y * 3)
                .setBarHeight(UNIT_DIV20_Y)
                .setItemHeight(UNIT_DIV20_Y)
                .addItems(Arrays.asList("Left", "Right"))
                .setType(ScrollableList.DROPDOWN) // currently supported DROPDOWN and LIST
                .close()
                .setFont(subFont)
                ;
            handedness.getCaptionLabel().align(ControlP5.LEFT, ControlP5.CENTER);
            tbox_len = cp5.addTextfield("Length")
                .setPosition(UNIT_DIV20_X * 11, UNIT_DIV20_Y)
                .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
                .setFont(subFont)
                ;
            tbox_cir = cp5.addTextfield("Circumference")
                .setPosition(UNIT_DIV20_X * 14, UNIT_DIV20_Y)
                .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
                .setFont(subFont)
                ;

            button_save = cp5.addButton("SaveButton")
                .setLabel("Save")
                .setPosition(UNIT_DIV20_X * 17, UNIT_DIV20_Y)
                .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
                .setColorBackground(clr_button_yet)
                .setFont(subFont)
                ;
            button_start = cp5.addButton("StartButton")
                .setLabel("Start")
                .setPosition(UNIT_DIV20_X * 17, UNIT_DIV20_Y * 5)
                .setSize(UNIT_DIV20_X * 2 , UNIT_DIV20_Y)
                .setColorBackground(clr_button_yet)
                .setFont(subFont)
                ;

            //  for indicationg wave form
            waveIndicator = cp5.addChart("dataflow")
                .setSize(UNIT_DIV20_X * 6, UNIT_DIV20_Y * 7)
                .setPosition(UNIT_DIV20_X * 4, UNIT_DIV20_Y * 7)
                .setRange(-10, 10)
                .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
                .setStrokeWeight(1.5)
                .setColorCaptionLabel(color(100))
                .setColorBackground(0)
                .setFont(subFont)
                ;
            waveIndicator.addDataSet("incoming");
            waveIndicator.setData("incoming", new float[300]);
            waveIndicator.setColors("incoming", color(200,40,100));
            //  for indicating amount of current
            currentHGage = new SmoothBarGage(
                cp5.addSlider("current")
                .setSize(UNIT_DIV20_X, UNIT_DIV20_Y * 7 / 2)
                .setPosition(UNIT_DIV20_X, UNIT_DIV20_Y * 7)
                .setRange(0,4095)
                .showTickMarks(true)
                .setHandleSize(UNIT_DIV20_X / 80)
                .setSliderMode(Slider.FIX)
                .setColorForeground(color(200,40,100))
                .setColorCaptionLabel(color(200,200,200))
                .setColorBackground(0)
                .setFont(subFont)
            );
            currentHGage.slider.getValueLabel().setVisible(false);
            //  for how the procedure is completed
            completeGage = new SmoothBarGage(
                cp5.addSlider("CompleteRate")
                .setLabel("Complete Rate")
                .setSize(WINDOW_X, UNIT_DIV20_Y / 2)
                .setPosition(0, WINDOW_Y - UNIT_DIV20_Y / 2)
                .setRange(0, 100)
                .setValue(0)
                .setColorBackground(0)
            );
            completeGage.slider.getCaptionLabel()
                .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE)
                .setFont(subFont)
                ;
            completeGage.slider.getValueLabel()
                .align(ControlP5.RIGHT, ControlP5.CENTER)
                .setFont(mainFont);

        }
        //  for cursor
        cursor_speed = 0.2;
        SEL_CORD = new Left_Right_Cord(
            new PVector(UNIT_DIV20_X, UNIT_DIV20_Y * 16),
            new PVector(UNIT_DIV20_X * 10.5, UNIT_DIV20_Y * 16)
        );
        cursor_cord = SEL_CORD.getCord(Left_Right.LEFT);

        //
        //  User Data
        //
        flowStatus = FlowState.OUT_OF_PROC;
        userCursor = Left_Right.LEFT;
        stimState = Left_Right.LEFT;

    }


    //@Override
    public void controlEvent(ControlEvent e)
    {
        switch (e.getController().getName()) {
            case "SerialPort":
                portindex = (int)e.getValue();
                break;
            case "Handedness":
                handindex = (int)e.getValue();
                break;
            case "SaveButton":
                if(!button_saveF) {
                    saveButtonL.actionPerformed(new ActionEvent(this, 0, "SaveButton"));
                }
                if (button_saveF){
                    button_save.setColorBackground(clr_button_done);
                    button_save.setLabel("Done");
                }
                break;
            case "StartButton":
                if(button_saveF && !button_startF) {
                    startButtonL.actionPerformed(new ActionEvent(this, 0, "StartButton"));
                }
                if(button_startF) {
                    button_start.setColorBackground(clr_button_done);
                    button_start.setLabel("Started");
                }
                break;	
        }

    }


    private void draw_flow()
    {
        int cunit;
        int order = 0;

        for (FlowState itr : FlowState.values()){
            if (itr == FlowState.OUT_OF_PROC) continue;
            else if (flowStatus == itr) 
                cunit = clrunit;
            else
                cunit = (int)(clrunit * 0.2f);
            pushMatrix();
            noStroke();
            if (itr != FlowState.COMPARING) 
                fill(cunit, cunit * 2, cunit);
            else
                fill(cunit * 2, cunit / 4, cunit);
            translate(UNIT_DIV20_X * 11, UNIT_DIV20_Y * (8 + 1.5 * order));
            ellipse(0, 0, UNIT_DIV20_Y, UNIT_DIV20_Y);
            popMatrix();

            pushMatrix();
            fill(cunit * 2);
            translate(UNIT_DIV20_X * 12, UNIT_DIV20_Y * (8 + 1.5 * order));
            text(itr.getCaption(), 0, 0);
            popMatrix();

            order++;
        }
    }

    private void draw_cursor ()
    {
        int cunit;

        if (flowStatus == FlowState.COMPARING) 
            cunit = clrunit;
        else 
            cunit = (int)(clrunit * 0.2f);
        pushMatrix();
        noStroke();
        fill(cunit * 2, cunit / 4, cunit);
        cursor_cord.x += cursor_speed * (SEL_CORD.getCord(userCursor).x - cursor_cord.x);
        if (abs(cursor_cord.x - SEL_CORD.getCord(userCursor).x) < 0.01) 
            cursor_cord = SEL_CORD.getCord(userCursor).copy();
        translate(cursor_cord.x, cursor_cord.y);
        rect(0, 0, UNIT_DIV20_X * 8.5, UNIT_DIV20_Y * 3, 5);
        popMatrix();
    }

    private void draw_stimopt ()
    {
        int cunit;
        for (Left_Right itr : Left_Right.values()){
            if (stimulationF && flowStatus != FlowState.OUT_OF_PROC && stimState == itr)
                cunit  = clrunit;
            else
                cunit = (int)(clrunit * 0.2f);
            pushMatrix();
            stroke(0, 0, cunit);
            fill(cunit/10, cunit * 2 / 3, cunit * 2);
            translate(SEL_CORD.getCord(itr).x, SEL_CORD.getCord(itr).y);
            rect(UNIT_DIV20_X, UNIT_DIV20_Y / 2 ,UNIT_DIV20_X * 6.5, UNIT_DIV20_Y * 2);
            popMatrix();
        }
    }
    public void update()
    {
        this.draw_flow();
        this.draw_cursor();
        this.draw_stimopt();
        currentHGage.update();
        completeGage.update();
    }
    public void updatePulseMonitor(int arg_fc, int arg_ph, int arg_pp, int arg_pw)
    {
        // unshift: add data from left to right (first in) //myChart.unshift("incoming", (sin(frameCount*0.1)*20));
        
        // push: add data from right to left (last in)
        //  In the case to show 6 period when pp = 2500 [us], buffer size = 300
        //  size of time window = 15000 [us]
        //  one frame = 50 [us]
        if((arg_fc % (arg_pp / 50)) < ((arg_pp - arg_pw) / 50))
            waveIndicator.push("incoming", 0);
        else
            waveIndicator.push("incoming", 10 * (float)arg_ph / 4095f);
    }
    //
    //  setters & getter of variables
    //
    public void         setFlowState(FlowState arg_val) { flowStatus = arg_val; }
    public FlowState    getFlowStatus() { return flowStatus; }
    public void         setCursor(Left_Right arg_val) { userCursor = arg_val; }
    public Left_Right   getCursor() { return userCursor; }
    public void         setStimState(Left_Right arg_val) { stimState = arg_val; stimulationF = true;}
    public Left_Right   getStimState() { return stimState; }
    public void         setStimulationOFF() {stimulationF = false;}
    public void     setCurrentHGageValue(float arg_ratio) { currentHGage.setRatio(arg_ratio); }
    public float    getcurrentHGageValue() { return currentHGage.getRatio(); }
    public void     setCompleteGageValue(float arg_ratio) { completeGage.setRatio(arg_ratio); }
    public float    getCompleteGageValue() { return completeGage.getRatio(); }

    public void     setSaveButtonFlag(boolean b) { button_saveF = b; }
    public boolean  getSaveButtonFlag(){return button_saveF;}
    public void     setSaveButtonListener (ActionListener l) { saveButtonL = l; }
    public void     fireSaveButton(){ button_save.update(); }

    public void     setStartButtonFlag(boolean b) { button_startF = b; }
    public boolean  getStartButtonFlag(){return button_startF;}
    public void     setStartButtonListener(ActionListener l) { startButtonL = l; }
    public void     fireStartButton(){ button_start.update(); }

    public void     addItems_ofPortList(String[] arg_s) { portlist.addItems(arg_s); }
    

    //
    //  getter of User Initial data
    //
    public String getPortName()
    {
        String l_name = "";

        if (portindex > -1)
            l_name = portlist.getItem(portindex).get("name").toString(); 
        println(l_name);

        return l_name;
    }
    public String getUserName()
    {
        return tbox_name.getText();
    }
    public String getHandedness()
    {
        String l_name = ""; 

        if (handindex > -1)
            l_name = handedness.getItem(handindex).get("name").toString(); 
        println(l_name);

        return l_name;
    }
    public int getLength()
    {
        int retval = -1; 
        try{
            retval = Integer.parseInt(tbox_len.getText());
        }
        catch (NumberFormatException e){
            println("non integer was input in len\n\t" + e);
        }
        return retval;
    }
    public int getCircumference()
    {
        int retval = -1; 
        try{
            retval = Integer.parseInt(tbox_cir.getText());
        }
        catch (NumberFormatException e){
            println("non integer was input in circumference\n\t" + e);
        }
        return retval;
    }
}