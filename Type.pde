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
float radius = 0.5;


// Text variables
String input = "";

class Type {

  // Type
  void init(){

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

  void handleInput(){

    pg.beginDraw();
    pg.fill(255);
    pg.textAlign(CENTER, CENTER);

    // Fitted text
    fitText(input, font, pg, w/2, pg.textAscent()/3, w, h);

    pg.endDraw();
  }

  void fitText(String text, PFont font, PGraphics p, float posX, float posY, float fitX, float fitY){
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

  void display(){
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
        pArray[x][y] = (float)simplexNoise.eval(x / (0.1 + mx / wi * 100.0), y / (0.1 + my / hi * 100.0), radius * cos(TWO_PI * t), radius * sin(TWO_PI * t)) * scale;
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

  void update(){
    // Check for change in pixel size
    w = width/pixelSize;
    h = height/pixelSize;

    // Re-Initialise pixel array
    pArray = new float[w][h];
  }

  void keyInput(){

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

  void debug(){
    // println(input);
    println(pixelSize);
  }
}
