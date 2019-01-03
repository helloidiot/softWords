Textlabel fpsLbl;

// Sliders
float sFrequency = 0.01;
int sMX = width/2;
int sMY = height/2;

// Motion blur
int sNumFrames = 96;

class GUI {

  void init(PApplet p){

    cp5 = new ControlP5(p);
    cp5.setAutoDraw(false);

    //FPS
    fpsLbl = new Textlabel(cp5,"FPS", 10, 10, 128, 20);

    createButtons();
    createSliders();

  }

  void display(PApplet p){
    // draw the GUI outside of the camera's view
    hint(DISABLE_DEPTH_TEST);
    fill(255);
    rect(0, pgH, pgW, height - pgH);
    cp5.draw();
    drawLabels(p);
    hint(ENABLE_DEPTH_TEST);
  }

  void drawLabels(PApplet p){
    fpsLbl.setValueLabel("FPS: " + floor(frameRate));
    fpsLbl.draw(p);
  }

  void createButtons(){

    int buttonGap = 30;
    int buttonWidth = 100;
    int buttonHeight = 20;
    int buttonPosX = width-(buttonWidth*2);
    int buttonPosY = height - buttonGap;

    cp5.addToggle("mode").setLabel("mode").setPosition(buttonPosX,buttonPosY).setSize(buttonWidth,buttonHeight);
  }

  void createSliders(){

    int sliderWidth = 100;
    int sliderHeight = 20;
    int sliderPosX = sliderWidth/2;
    int sliderPosY = 700 + sliderHeight;
    int sliderGap = 30;

    // Frequency
    cp5.addSlider("sFrequency").setLabel("frequency").setRange(0.001,0.05).setValue(0.01).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);

    // Noise
    cp5.addSlider("sMX").setLabel("mX").setRange(0,width).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);
    cp5.addSlider("sMY").setLabel("mY").setRange(0,height).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);

    cp5.addSlider("sNumFrames").setLabel("numFrames").setRange(1,400).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);

    println(pgH);
  }

}  // End GUI class
