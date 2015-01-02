import beads.*; // import the beads library

final int MARGIN = 20;
final int BOX_SIZE = 100;
final int TEXT_X_OFFSET = 30;
final int TEXT_Y_OFFSET = 65;
final int LISTEN_BC = 180;
final int NORMAL_BC = 80;
final int FRAME_RATE = 30;
final int DOWN_TIME = 18;
final int INTERVAL_TIME = 14;

char[] letters = {'q', 'w', 'e', 'r'};
color[] colors = {#FF0000, #00A000, #3060FF, #FFFF00};
int[] buttonFreqs = {200, 300, 400, 500};
int gameOverFreq = 60;
boolean[] lit = {false, false, false, false};

ArrayList<Integer> pattern = new ArrayList<Integer>();
int patternIndex = 0;

int timer = 0;
// State machine
final int ST_ADD = 1;
final int ST_PAUSE = 2;
final int ST_PLAY = 3;
final int ST_LISTEN = 4;
final int ST_PRESSED = 5;
final int ST_END = 6;

int state;

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
  lit[buttonNum] = true;
  timer = DOWN_TIME; 
  wp.setFrequency(buttonFreqs[buttonNum]);
  env.addSegment(0.5, 20);
  env.addSegment(0.4, 400);
  env.addSegment(0.0, 50);
}

void clearButtons() {
  for (int i = 0; i < lit.length; i++) {
    lit[i] = false;
  }
}

boolean buttonsLit() {
  for (int i = 0; i < lit.length; i++) {
    if (lit[i]) {
      return true;
    }
  }
  return false;
}

void keyPressed() {
  int num = letterToInt(key);
  if (state == ST_LISTEN && num > -1) {
    if (num == pattern.get(patternIndex).intValue()) {
      playButton(num);
      patternIndex++;
      state = ST_PRESSED;
    } else {
      wp.setFrequency(gameOverFreq);
      env.addSegment(0.5, 20);
      env.addSegment(0.4, 1000);
      env.addSegment(0.0, 50);
      state = ST_END;
    }
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
  
  state = ST_ADD;
}

void draw() {
  switch (state) {
    case ST_ADD:
      background(NORMAL_BC);
      pattern.add(new Integer(floor(random(letters.length))));
      patternIndex = 0;
      timer = INTERVAL_TIME;
      state = ST_PAUSE;
      break;
    case ST_PAUSE:
      background(NORMAL_BC);
      if (timer > 0) {
        timer--;
      } else {
        clearButtons();
        if (patternIndex < pattern.size()) {
          state = ST_PLAY;
        } else {
          patternIndex = 0;
          state = ST_LISTEN;
        }
      }
      break;
    case ST_PLAY:
      background(NORMAL_BC);
      playButton(pattern.get(patternIndex).intValue());
      patternIndex++;
      state = ST_PAUSE;
      break;
    case ST_LISTEN:
      background(LISTEN_BC);
      break;
    case ST_PRESSED:
      background(LISTEN_BC);
      if (timer > 0) {
        timer--;
      } else {
        clearButtons();
        if (patternIndex < pattern.size()) {
          state = ST_LISTEN;
        } else {
          state = ST_ADD;
        }
      }
      break;
    default:
      background(NORMAL_BC);
      fill(255);
      text("Game Over: " + (pattern.size() - 1), 30, height/2 + 20);
  }
  if (state != ST_END) {
    for (int i = 0; i < letters.length; i++) {
      drawBox(i, lit[i]);
    }
  }
}

