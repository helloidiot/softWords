Textlabel fpsLbl;
int sliderWidth = 100;

// Sliders
float sFrequency = 0.01;

class GUI {

  void init(PApplet p){

    cp5 = new ControlP5(p);
    cp5.setAutoDraw(false);

    //FPS
    fpsLbl = new Textlabel(cp5,"FPS", 10, 10, 128, 20);

    createSliders();

  }

  void display(PApplet p){
    // draw the GUI outside of the camera's view
    hint(DISABLE_DEPTH_TEST);
    cp5.draw();
    drawLabels(p);
    hint(ENABLE_DEPTH_TEST);
  }

  void drawLabels(PApplet p){
    fpsLbl.setValueLabel("FPS: " + floor(frameRate));
    fpsLbl.draw(p);
  }

  void createSliders(){
    // Frequency
    cp5.addSlider("sFrequency").setRange(0.001,0.05).setValue(0.01).setPosition(width-sliderWidth,20).setSize(sliderWidth,10);

  }

}  // End GUI class
