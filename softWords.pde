// TO DO
// Text moves onto new line
// Render pixels in a different way so no gaps
// ControlP5 to allow for variable control
// Add Bees and bombs motion blur
// Etienne Jacob gif export
// More ways of drawing otehr than grid -

import controlP5.*;

GUI gui;
Type type;

OpenSimplexNoise simplexNoise;
ControlP5 cp5;

// Motion blur
int[][] result;
float t, c;
float mn = .5 * sqrt(3);
float ia = atan(sqrt(.5));
int samplesPerFrame = 5; // times to sample each frame
int numFrames = 96; // 4 secs at 24fps
float shutterAngle = 1.5; // 180 degree shutter
boolean recording = false;
float recordingStart;
int time = 1;
float speed = 0.01;

void settings(){
  size(800,800);

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
    type.display();
  }
  else {
    motionBlur();
  }

  gui.display(this);
 }

// Bees & bombs motion blur
void motionBlur(){
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

  saveFrame("softWords" + time + ".png");
  println(time,"/",numFrames);

  time++;

  if ((time-recordingStart)==numFrames){
    exit();
  }
}

void keyPressed(){
  // At some point change this to a GUI input
  if (keyCode == UP){
    recordingStart = time;
    recording = true;
  }
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
