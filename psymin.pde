import beads.*; // import the beads library

int MARGIN = 20;
int BOX_SIZE = 100;
int TEXT_X_OFFSET = 30;
int TEXT_Y_OFFSET = 65;
int FRAME_RATE = 30;
int DOWN_TIME = 20;

char[] letters = {'q', 'w', 'e', 'r'};
color[] colors = {#FF0000, #00A000, #3060FF, #FFFF00};
int[] buttonTimers = {0, 0, 0, 0};
int[] buttonFreqs = {200, 300, 400, 500};

boolean repeatMode = true;

PFont font;

AudioContext ac; // create our AudioContext

WavePlayer wp;
Envelope env;
Gain g;

int letterToInt(char letter) {
  for (int i = 0; i < letters.length; i++) {
    if (letters[i] == letter) {
      return i;
    }
  }
  return -1;
}

char intToLetter(int i) {
  if (i >= 0 && i < letters.length) {
    return letters[i];
  } else {
    return '\0';
  }
}

void drawBox(int index, boolean lit) {
  int x = index * (MARGIN + BOX_SIZE) + MARGIN;
  int y = MARGIN;
  fill(lit ? colors[index] : 0);
  rect(x, y, BOX_SIZE, BOX_SIZE);
  fill(lit ? 0 : colors[index]);
  text(intToLetter(index), x + TEXT_X_OFFSET, y + TEXT_Y_OFFSET);  
}

void playButton(int buttonNum) {
  buttonTimers[buttonNum] = DOWN_TIME; 
  wp.setFrequency(buttonFreqs[buttonNum]);
  env.addSegment(0.5, 20);
  env.addSegment(0.4, 400);
  env.addSegment(0.0, 50);
}

boolean buttonsPlaying() {
  for (int i = 0; i < buttonTimers.length; i++) {
    if (buttonTimers[i] > 0) {
      return true;
    }
  }
  return false;
}  

void decrementTimers() {
  for (int i = 0; i < buttonTimers.length; i++) {
    if (buttonTimers[i] > 0) {
      buttonTimers[i]--;
    }
  }
}

void keyPressed() {
  int num = letterToInt(key);
  if (repeatMode && !buttonsPlaying() && num > -1) {
    playButton(num);
  }
}

void setup() {
  int h = BOX_SIZE + MARGIN * 2;
  int w = letters.length * (BOX_SIZE + MARGIN) + MARGIN;
  size(w, h);
  frameRate(FRAME_RATE);
  font = loadFont("GillSansMT-Bold-60.vlw");
  textFont(font);
  noStroke();

  // Audio setup
  ac = new AudioContext();
  wp = new WavePlayer(ac, 400, Buffer.SQUARE);
  env = new Envelope(ac);
  g = new Gain(ac, 1, env);
  g.addInput(wp);
  ac.out.addInput(g);
  ac.start();
}

void draw() {
  background(repeatMode ? 180 : 90);
  for (int i = 0; i < letters.length; i++) {
    drawBox(i, buttonTimers[i] > 0);
  }
  decrementTimers();
}

