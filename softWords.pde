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

import controlP5.*;

// Class declerations
GUI gui;
Type type;

OpenSimplexNoise simplexNoise;
ControlP5 cp5;

void settings(){
  size(700,1000);

  // 8x anti-aliasing, not sure if this does anything...
  smooth(8);
}

void setup() {

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

void draw() {
  background(0);

  if (!recording) {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
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
float mn = .5 * sqrt(3);
float ia = atan(sqrt(.5));
int samplesPerFrame = 5; // times to sample each frame
int numFrames; // 4 secs at 24fps
float shutterAngle = 1.5; // 180 degree shutter
boolean recording = false;
float recordingStart;
int time = 1;
float speed = 0.01;

void motionBlur(){

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
    int(result[i][0]*1.0/samplesPerFrame) << 16 |
    int(result[i][1]*1.0/samplesPerFrame) << 8 |
    int(result[i][2]*1.0/samplesPerFrame);
  }
  updatePixels();

  saveFrame("img/softWords" + time + ".png");
  println(time,"/",numFrames);

  time++;

  if ((time-recordingStart)==numFrames){
    exit();
  }
}

void keyPressed(){
  // At some point change this to a GUI input
  type.keyInput();
}

// Helpers / easing
float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5)
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}
