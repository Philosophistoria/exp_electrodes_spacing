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

public class Exp_GUI 
implements ControlListener
{
    //  GUI objects
    ControlP5 cp5;
    class SmoothBarGage 
    {
        Slider slider;
        float buffer;
        float rate;
        public SmoothBarGage (Slider s, float arg_rate){
            slider = s;
            buffer = s.getMin();
            rate = arg_rate;
        }
        public SmoothBarGage (Slider s){
            this(s, 0.4f);
        }
    }
    public SmoothBarGage currentHGage;
    public SmoothBarGage completeGage;
    public Chart waveIndicator;
    public ScrollableList portlist, handedness;
    private Integer portindex = -1, handindex = -1;
    public Textfield tbox_name, tbox_len, tbox_cir; 
    public Button button_save, button_start;

    //  Constants & Variable for controlling the cursor
    final float cursor_speed;
    final PVector[] sel_cord;
    PVector cursor_cord;

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


    public Exp_GUI (PApplet theParent, int arg_WINDOW_X, int arg_WINDOW_Y)
    {
        WINDOW_X = arg_WINDOW_X;
        WINDOW_Y = arg_WINDOW_Y;
        UNIT_DIV20_X = WINDOW_X / 20;
        UNIT_DIV20_Y = WINDOW_Y / 20;

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

        //
        //  GUI Setup
        //
        cp5 = new ControlP5(theParent);
        cp5.addListener(this);
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

        //  for cursor
        cursor_speed = 0.2;
        sel_cord = new PVector[]{
            new PVector(UNIT_DIV20_X, UNIT_DIV20_Y * 16),
            new PVector(UNIT_DIV20_X * 10.5, UNIT_DIV20_Y * 16)
        };
        cursor_cord = sel_cord[0];

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
    //
    //  public method
    //

    final String[] flowCapion = {
        "(Reference)  Cutaneous Thre.",
        "(Reference)  Proprioceptive Thre.",
        "(Reference)  Pain Thre.",
        "(Comparison) Cutaneous Thre.",
        "Select one FORCE sens. is STRONGER"
    };

    public void toggle_flow(int arg_val)
    {
        int cunit;
        int num_item = 5;

        for (int i = 0; i < num_item - 1; i++){
            if ((num_item - i + arg_val) % num_item == 0) 
                cunit = clrunit;
            else
                cunit = (int)(clrunit * 0.2f);
            pushMatrix();
            noStroke();
            fill(cunit, cunit * 2, cunit);
            translate(UNIT_DIV20_X * 11, UNIT_DIV20_Y * (8 + 1.5 * i));
            ellipse(0, 0, UNIT_DIV20_Y, UNIT_DIV20_Y);
            popMatrix();

            pushMatrix();
            fill(cunit * 2);
            translate(UNIT_DIV20_X * 12, UNIT_DIV20_Y * (8 + 1.5 * i));
            text(flowCapion[i], 0, 0);
            popMatrix();
        }
        //  last one has different color
        {
            if ((num_item - 4 + arg_val) % num_item == 0) 
                cunit = clrunit;
            else
                cunit = (int)(clrunit * 0.2f);
            pushMatrix();
            noStroke();
            fill(cunit * 2, cunit / 4, cunit);
            translate(UNIT_DIV20_X * 11, UNIT_DIV20_Y * (8 + 1.5 * 4));
            ellipse(0, 0, UNIT_DIV20_Y, UNIT_DIV20_Y);
            popMatrix();

            pushMatrix();
            fill(cunit * 2);
            translate(UNIT_DIV20_X * 12, UNIT_DIV20_Y * (8 + 1.5 * 4));
            text(flowCapion[4], 0, 0);
            popMatrix();
        }
    }

    public void toggle_selection (int arg_val, boolean arg_visible)
    {
        int cunit;

        if (arg_visible) 
            cunit = clrunit;
        else 
            cunit = (int)(clrunit * 0.2f);
        pushMatrix();
        noStroke();
        fill(cunit * 2, cunit / 4, cunit);
        cursor_cord.x += cursor_speed * (sel_cord[arg_val].x - cursor_cord.x);
        if (abs(cursor_cord.x - sel_cord[arg_val].x) < 0.01) 
            cursor_cord = sel_cord[arg_val].copy();
        translate(cursor_cord.x, cursor_cord.y);
        rect(0, 0, UNIT_DIV20_X * 8.5, UNIT_DIV20_Y * 3, 5);
        popMatrix();
    }

    public void toggle_stimopt (int arg_val)
    {
        int cunit;
        for (int i = 0; i < 2; i++){
            if ((2 - i + arg_val) % 2 == 0)
                cunit  = clrunit;
            else
                cunit = (int)(clrunit * 0.2f);
            pushMatrix();
            stroke(0, 0, cunit);
            fill(cunit/10, cunit * 2 / 3, cunit * 2);
            translate(sel_cord[i].x, sel_cord[i].y);
            rect(UNIT_DIV20_X, UNIT_DIV20_Y / 2 ,UNIT_DIV20_X * 6.5, UNIT_DIV20_Y * 2);
            popMatrix();
        }
    }
    //
    //  setters
    //
    public void setSaveButtonFlag(boolean b)
    {
        button_saveF = b;
    }
    public void setStartButtonFlag(boolean b)
    {
        button_startF = b;
    }
    public void setSaveButtonListener (ActionListener l)
    {
        saveButtonL = l;
    }
    public void setStartButtonListener(ActionListener l)
    {
        startButtonL = l;
    }
    public void addItems_ofPortList(String[] arg_s)
    {
        portlist.addItems(arg_s);
    }
    public void updateGageValue(SmoothBarGage arg_gage, float arg_rateval)
    {
        arg_gage.buffer += arg_gage.rate * (arg_rateval - arg_gage.buffer);
        if(abs(arg_gage.buffer - arg_rateval) < 0.01) arg_gage.buffer = arg_rateval;
        setGageValue(arg_gage.slider, arg_gage.buffer);
    }
    private void setGageValue(Slider arg_gage, float arg_rateval)
    {
        arg_gage.setValue(
            arg_gage.getMin() 
            + arg_rateval * (arg_gage.getMax() - arg_gage.getMin())
        );
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
    //  getter
    //
    public boolean getSaveButtonFlag()
    {
        return button_saveF;
    }
    public boolean getStartButtonFlag()
    {
        return button_startF;
    }
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