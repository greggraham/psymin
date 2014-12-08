char[] letters = {'q', 'w', 'e', 'r'};
color[] colors = {#FF0000, #00FF00, #3060FF, #FFFF00};
PFont font;
int MARGIN = 20;
int BOX_SIZE = 100;
int TEXT_X_OFFSET = 30;
int TEXT_Y_OFFSET = 65;

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

void setup() {
  int h = BOX_SIZE + MARGIN * 2;
  int w = letters.length * (BOX_SIZE + MARGIN) + MARGIN;
  size(w, h);
  font = loadFont("GillSansMT-Bold-60.vlw");
  textFont(font);
  noStroke();
}

void draw() {
  background(50);
  for (int i = 0; i < letters.length; i++) {
    drawBox(i, keyPressed && key == intToLetter(i));
  }
}

