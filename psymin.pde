import beads.*;

// Constants
final int MARGIN = 20;
final int BOX_SIZE = 100;
final int TEXT_X_OFFSET = 30;
final int TEXT_Y_OFFSET = 65;
final int LISTEN_BC = 180;
final int NORMAL_BC = 80;
final int FRAME_RATE = 30;
final int LIT_TIME = 18;
final int INTERVAL_TIME = 14;
final int GAME_OVER_FREQ = 60;

// Button arrays
char[] letters = {'q', 'w', 'e', 'r'};
color[] colors = {#FF0000, #00A000, #3060FF, #FFFF00};
int[] buttonFreqs = {200, 300, 400, 500};
boolean[] lit = {false, false, false, false};

// Pattern storage
ArrayList<Integer> pattern = new ArrayList<Integer>();
int patternIndex = 0;

// State machine
final int ST_ADD = 1;
final int ST_PAUSE = 2;
final int ST_PLAY = 3;
final int ST_LISTEN = 4;
final int ST_PRESSED = 5;
final int ST_END = 6;
int state;
int timer;

// Text font
PFont font;

// Variables for the Beads sound library
AudioContext ac;
WavePlayer wp;
Envelope env;
Gain g;

// Convert from a button's key letter to its integer position
int letterToInt(char letter) {
  for (int i = 0; i < letters.length; i++) {
    if (letters[i] == letter) {
      return i;
    }
  }
  return -1;
}

// Convert from a button's integer position to its key letter
char intToLetter(int i) {
  if (i >= 0 && i < letters.length) {
    return letters[i];
  } else {
    return '\0';
  }
}

// Draw the button boxes
void drawBox(int index, boolean lit) {
  int x = index * (MARGIN + BOX_SIZE) + MARGIN;
  int y = MARGIN;
  
  // Draw box filled with color if lit, otherwise black.
  fill(lit ? colors[index] : 0);
  rect(x, y, BOX_SIZE, BOX_SIZE);
  
  // Draw text (key letter corresponding to the button) black if button
  // is lit, otherwise colored.
  fill(lit ? 0 : colors[index]);
  text(intToLetter(index), x + TEXT_X_OFFSET, y + TEXT_Y_OFFSET);  
}

// Light up a button and play its tone
void playButton(int buttonNum) {
  lit[buttonNum] = true;
  
  // Set timer to keep button lit for a certain time.
  timer = LIT_TIME; 
  wp.setFrequency(buttonFreqs[buttonNum]);
  env.addSegment(0.5, 20);  // 20 ms attack
  env.addSegment(0.5, 400); // sustain for 400 ms
  env.addSegment(0.0, 50);  // 50 ms release
}

// Unlight all of the buttons
void clearButtons() {
  for (int i = 0; i < lit.length; i++) {
    lit[i] = false;
  }
}

// Determine if any buttons are currently lit
boolean buttonsLit() {
  for (int i = 0; i < lit.length; i++) {
    if (lit[i]) {
      return true;
    }
  }
  return false;
}

// Respond to key presses
void keyPressed() {
  
  // Translate the key to a button number value.
  int num = letterToInt(key);
  
  // Only accept a keypress in the listen state, and ignore keys that
  // are not designated keys for the game, indicated by a value of -1.
  if (state == ST_LISTEN && num > -1) {
    if (num == pattern.get(patternIndex).intValue()) {
      
      // The button pressed by the player matches the pattern. Light the button, play the tone,
      // advance the pattern index, and transition to the state that gives time for the button
      // to show.
      playButton(num);
      patternIndex++;
      state = ST_PRESSED;
    } else {
      
      // The incorrect button was pressed. Sound a buzzing tone and transition to end state.
      wp.setFrequency(GAME_OVER_FREQ);
      env.addSegment(0.5, 20);  // 20 ms attack
      env.addSegment(0.5, 1000);  // sustain for 1 second
      env.addSegment(0.0, 50);  // 50 ms release
      state = ST_END;
    }
  }
}

// Processing setup function
void setup() {
  // Setup the window and other Processing parameters
  size(500, 140);
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
  
  // Initial state
  state = ST_ADD;
}

// Processing draw function
void draw() {
  
  // This switch statement contains the state machine.
  switch (state) {
    
    // Add an element to the pattern.
    case ST_ADD:
      background(NORMAL_BC);
      
      // A random number is added to an ArrayList containing the pattern. Since ArrayLists must
      // have objects as elements, the number has to be put into an Integer object.
      pattern.add(new Integer(floor(random(letters.length))));
      
      // Get ready for playing the newly extended pattern
      patternIndex = 0;
      
      // Transition to the pause state
      timer = INTERVAL_TIME;
      state = ST_PAUSE; 
      break;
      
    // Pause before showing an element in the pattern.
    case ST_PAUSE:
      background(NORMAL_BC);
      
      if (timer > 0) {
        
        // countdown the timer
        timer--;
      } else {
        
        // Timer is expired, clear any lit buttons.
        clearButtons();
        
        // Either continue playing the pattern, or transition to listen state so that player can
        // give us the pattern.
        if (patternIndex < pattern.size()) {
          
          // Transition to state to play the next pattern element.
          state = ST_PLAY;
        } else {
          
          // Transition to state to listen for player response.
          patternIndex = 0;
          state = ST_LISTEN;
        }
      }
      break;
      
    // Show an element in the pattern.
    case ST_PLAY:
      background(NORMAL_BC);
      
      // Play the current element in the pattern, and increment the index to be ready
      // for playing the next element.
      playButton(pattern.get(patternIndex).intValue());
      patternIndex++;
      
      // Transition to pause state
      state = ST_PAUSE;
      break;
      
    // Wait for the player to respond.
    case ST_LISTEN:
      background(LISTEN_BC);
      break;
    
    // Show the player's response by lighting the button and playing its tone.
    case ST_PRESSED:
      background(LISTEN_BC);
      if (timer > 0) {
        
        // countdown the timer
        timer--;
      } else {
        
        // Timer is expired, clear any lit buttons.
        clearButtons();
        
        // Either continue listening, or the player has completed the pattern, transition
        // to the state to add to the pattern.
        if (patternIndex < pattern.size()) {
          state = ST_LISTEN;
        } else {
          state = ST_ADD;
        }
      }
      break;
      
    // The default case is the Game Over end state.
    default:
      background(NORMAL_BC);
      fill(255);
      text("Game Over: " + (pattern.size() - 1), 30, height/2 + 20);
  }
  
  // Display the buttons.
  if (state != ST_END) {
    for (int i = 0; i < letters.length; i++) {
      drawBox(i, lit[i]);
    }
  }
}
