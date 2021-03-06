import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class softWords extends PApplet {

// TO DO
// -Mode selector-
// input / control
// -Text-
// Text is layed out nicely, centered and not overlapping screen
// Text moves onto new line
// -GUI-
// Extend ControlP5 for more control
// -Text drawing-
// Decreasing grid
// Circles draw



// Class declerations
GUI gui;
Type type;

OpenSimplexNoise simplexNoise;
ControlP5 cp5;

public void settings(){
  size(700,1000);

  // 8x anti-aliasing, not sure if this does anything...
  smooth(8);
}

public void setup() {

  // result contains the sums of the samples and is used to compute the motion blur average.
  result = new int[width*height][3];

  // GUI
  gui = new GUI();
  gui.init(this);

  // Typography
  type = new Type();
  type.init();

  noStroke();
}

public void draw() {
  background(0);

  if (!recording) {
    t = mouseX*1.0f/width;
    c = mouseY*1.0f/height;
    if (mousePressed){
      println(c);
    }
    type.display();
    // type.update();
  }
  else {
    motionBlur();
  }

  gui.display(this);
 }

// Bees & bombs motion blur
int[][] result;
float t, c;
float mn = .5f * sqrt(3);
float ia = atan(sqrt(.5f));
int samplesPerFrame = 5; // times to sample each frame
int numFrames; // 4 secs at 24fps
float shutterAngle = 1.5f; // 180 degree shutter
boolean recording = false;
float recordingStart;
int time = 1;
float speed = 0.01f;

public void motionBlur(){

  numFrames = sNumFrames;

  for (int i=0; i<width*height; i++){
    for (int a=0; a<3; a++){
      result[i][a] = 0;
    }
  }
  c = 0;

  for (int sa=0; sa<samplesPerFrame; sa++) {
    t = map(time-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);

    // Draw the image
    type.display();
    loadPixels();
    for (int i=0; i<pixels.length; i++) {
      result[i][0] += pixels[i] >> 16 & 0xff;
      result[i][1] += pixels[i] >> 8 & 0xff;
      result[i][2] += pixels[i] & 0xff;
    }
  }

  loadPixels();
  for (int i=0; i<pixels.length; i++){
    pixels[i] = 0xff << 24 |
    PApplet.parseInt(result[i][0]*1.0f/samplesPerFrame) << 16 |
    PApplet.parseInt(result[i][1]*1.0f/samplesPerFrame) << 8 |
    PApplet.parseInt(result[i][2]*1.0f/samplesPerFrame);
  }
  updatePixels();

  saveFrame("img/softWords" + time + ".png");
  println(time,"/",numFrames);

  time++;

  if ((time-recordingStart)==numFrames){
    exit();
  }
}

public void keyPressed(){
  // At some point change this to a GUI input
  type.keyInput();
}

// Helpers / easing
public float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

public float ease(float p, float g) {
  if (p < 0.5f)
    return 0.5f * pow(2*p, g);
  else
    return 1 - 0.5f * pow(2*(1 - p), g);
}

public void push() {
  pushMatrix();
  pushStyle();
}

public void pop() {
  popStyle();
  popMatrix();
}
Textlabel fpsLbl;

// Sliders
float sFrequency = 0.01f;
int sMX = width/2;
int sMY = height/2;

// Motion blur
int sNumFrames = 96;

class GUI {

  public void init(PApplet p){

    cp5 = new ControlP5(p);
    cp5.setAutoDraw(false);

    //FPS
    fpsLbl = new Textlabel(cp5,"FPS", 10, 10, 128, 20);

    createButtons();
    createSliders();

  }

  public void display(PApplet p){
    // draw the GUI outside of the camera's view
    hint(DISABLE_DEPTH_TEST);
    fill(255);
    rect(0, pgH, pgW, height - pgH);
    cp5.draw();
    drawLabels(p);
    hint(ENABLE_DEPTH_TEST);
  }

  public void drawLabels(PApplet p){
    fpsLbl.setValueLabel("FPS: " + floor(frameRate));
    fpsLbl.draw(p);
  }

  public void createButtons(){

    int buttonGap = 30;
    int buttonWidth = 100;
    int buttonHeight = 20;
    int buttonPosX = width-(buttonWidth*2);
    int buttonPosY = height - buttonGap;

    cp5.addToggle("mode").setLabel("mode").setPosition(buttonPosX,buttonPosY).setSize(buttonWidth,buttonHeight);
  }

  public void createSliders(){

    int sliderWidth = 100;
    int sliderHeight = 20;
    int sliderPosX = sliderWidth/2;
    int sliderPosY = 700 + sliderHeight;
    int sliderGap = 30;

    // Frequency
    cp5.addSlider("sFrequency").setLabel("frequency").setRange(0.001f,0.05f).setValue(0.01f).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);

    // Noise
    cp5.addSlider("sMX").setLabel("mX").setRange(0,width).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);
    cp5.addSlider("sMY").setLabel("mY").setRange(0,height).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);

    cp5.addSlider("sNumFrames").setLabel("numFrames").setRange(1,400).setPosition(sliderPosX,(sliderPosY+=sliderGap)).setSize(sliderWidth,sliderHeight);

    println(pgH);
  }

}  // End GUI class
// Mode selector
boolean mode = true; // input = false, control = true
String currentMode = "";

// Pixel array
float[][] pArray;

PImage img;
PGraphics pg;
PFont font;

int pgW, pgH;

float frequency;
int w;
int h;

// Pixel size
int pixelSize = 2;

// Noise variables
float scale = 10;
float scl = 10;
float radius = 0.5f;


// Text variables
String input = "";

class Type {

  // Type
  public void init(){

    pgW = 700;
    pgH = 700;

    w = pgW/pixelSize;
    h = pgH/pixelSize;

    // Noise
    simplexNoise = new OpenSimplexNoise();

    pg = createGraphics(w, h);
    font = createFont("OpticianSans-Regular", 100);

    // Initialise pixel array
    pArray = new float[w][h];
  }

  public void handleInput(){

    pg.beginDraw();
    pg.fill(255);
    pg.textAlign(CENTER, CENTER);

    // Fitted text
    fitText(input, font, pg, w/2, pg.textAscent()/3, w, h);

    pg.endDraw();
  }

  public void fitText(String text, PFont font, PGraphics p, float posX, float posY, float fitX, float fitY){
    push();
    p.textFont(font);
    float txtSz = min(font.getSize() * fitX / p.textWidth(text), fitY);
    p.textSize(txtSz);

    // Create grid of words
    // Loop until we reach the bottom of the image
    while (posY < h-(pg.textAscent())){
      //// Reduce font size by half per line - NOT WORKING
      // float txtSz2 = min(font.getSize() * (fitX/2) / (p.textWidth(text)/2), fitY);
      // p.textSize(txtSz2);
      // p.scale(0.5);
      p.text(text, posX, posY);
      posY += p.textAscent();
    }
    pop();
  }

  public void display(){
    // Fill the buffer with text
    handleInput();

    for (int y = 0; y < h-1; y++) {

      frequency += sFrequency;
      float mx = sMX;
      float my = sMY;
      float wi = w;
      float hi = h;

      // Noise time
      // float t = 1.0 * time / numFrames;

      for (int x = 0; x < w-1; x++) {
        // No loop
        // pArray[x][y] = (float)simplexNoise.eval((x + frequency) / (0.1 + mx / wi * 100.0), (y + frequency) / (0.1 + my / hi * 100.0)) * scale;
        // pArray[x][y] = (float)simplexNoise.eval(scale*x,scale*y,radius*cos(TWO_PI*t),radius*sin(TWO_PI*t));
        // pArray[x][y] = (float)simplexNoise.eval((x + frequency) / (0.1 + mx / wi * 100.0),(y + frequency) / (0.1 + my / hi * 100.0),radius*cos(TWO_PI*t),radius*sin(TWO_PI*t));

        // Loop ?
        // pArray[x][y] = (float)simplexNoise.eval((x + frequency) / (0.1 + mx / wi * 100.0), (y + frequency) / (0.1 + my / hi * 100.0), radius * cos(TWO_PI * t), radius * sin(TWO_PI * t)) * scale;
        pArray[x][y] = (float)simplexNoise.eval(x / (0.1f + mx / wi * 100.0f), y / (0.1f + my / hi * 100.0f), radius * cos(TWO_PI * t), radius * sin(TWO_PI * t)) * scale;
        // Offsets the x & y position of the pixel by noise.
        // int x2 = (x+(int)pArray[x][y])*pixelSize;
        // int y2 = (y+(int)pArray[x][y])*pixelSize;

        // Float offset
        float x2 = (x+pArray[x][y])*pixelSize;
        float y2 = (y+pArray[x][y])*pixelSize;

        // Grab the colour from the image
        fill(pg.get(x,y));

        // Draw a rectangle for each pixel at the corresponding position
        rect(x2,y2, pixelSize, pixelSize);

        // if (get(x2, y2 - pixelSize) != img.get(x,y)){
        //   rect(x2,y2-pixelSize,pixelSize,pixelSize);
        // }
      }
    }
    pg.clear();
  }

  public void update(){
    // Check for change in pixel size
    w = width/pixelSize;
    h = height/pixelSize;

    // Re-Initialise pixel array
    pArray = new float[w][h];
  }

  public void keyInput(){

    if (keyCode == ENTER || keyCode == RETURN){
      // Mode switch
      mode = !mode;
      if (mode){
        currentMode = "input";
      }
      else {
        currentMode = "control";
      }
      println(currentMode);
    }

    // INPUT MODE
    if (mode){
      // Remove last entered letter
      if (keyCode == BACKSPACE){
          if (input.length() > 0){
              input = input.substring(0, input.length()-1);
          }
      }
      // Empty entry
      else if (keyCode == DELETE){
        input = "";
      }
      // Add entered key to String
      else {
        input = input + key;
      }
    }

    // CONTROL MODE
    if (!mode){
      if (keyCode == UP){
        recordingStart = time;
        recording = true;
      }

      // // Change scaling / pixelSize
      // else if (key == '='){
      //   pixelSize += 1;
      // }
      // else if (key == '-'){
      //   if (pixelSize != 1){
      //       pixelSize -= 1;
      //   }
      // }
    }


  }

  public void debug(){
    // println(input);
    println(pixelSize);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "softWords" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
