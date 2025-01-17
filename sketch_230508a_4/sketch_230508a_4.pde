import processing.video.*;
Capture video;

//statistics
boolean exportingStatistics = false;

//colors
color white = color(255);
color black = color(0);
color lightGray = color(235);
color gray = color (215);
color darkGray = color(110);

//measurements
int gap = 8; //measurement unit
int mainPadding = gap * 4;

//typography
int fontSizeTiny;
int fontSizeSmall;
int fontSizeMedium;
int fontSizeBig;
int fontSizeHuge;

PFont fontWeightLight;
PFont fontWeightRegular;
PFont fontWeightBold;

//major components
Header header;
Console console;

ScanScreen scanScreen;
EvolutionScreen evolutionScreen;

int currentScreen = 0;
int previousScreen = 0;

Button pressedButton;

//objects
PImage objectsHighRes[];
PImage objectsLowRes[];
int objectResolutionHigh = 1080;
int objectResolutionLow = 100;
int[] enabledShapeIndexes;

void settings() {
  fullScreen();
  //size(1720, 920);
}

void setup() {
  frameRate(120);

  if(Capture.list().length > 0){
    video = new Capture(this, 1920, 1080, Capture.list()[0]);
    video.start();
  }
  else {
    video = null;
  }

  loadFonts();
  loadObjects();
  calculateFontSizes();

  textFont(fontWeightRegular);

  float headerHeight = gap * 12;
  float consoleHeight = gap * 6;

  float screenWidth = width - mainPadding * 2;
  float screenHeight = height - headerHeight - consoleHeight - mainPadding * 2;

  scanScreen = new ScanScreen(screenWidth, screenHeight);
  evolutionScreen = new EvolutionScreen(screenWidth, screenHeight);

  header = new Header(headerHeight);
  console = new Console(consoleHeight);
}

void draw() {
  background(white);

  header.update();

  if (previousScreen != currentScreen && video != null) {
    if (currentScreen == 0) video.start();
    else video.stop();
  }

  pushMatrix();
  translate(mainPadding, header.h + mainPadding);
  switch(currentScreen) {
  case 0:
    scanScreen.update();
    scanScreen.show();
    break;
  case 1:
    evolutionScreen.update();
    evolutionScreen.show();
    break;
  }
  popMatrix();

  header.show();
  console.show();

  previousScreen = currentScreen;
}

void mouseReleased() {
  if (pressedButton == null) return;
  pressedButton.selected();
  pressedButton = null;
}


void stop(){
  
}

void loadObjects() {
  objectsHighRes = loadObjects(objectResolutionHigh);
  objectsLowRes = loadObjects(objectResolutionLow);
}

void loadFonts() {
  String directory = "fonts/WorkSans-";
  String fileType = ".ttf";
  int fontSize = 32;

  fontWeightLight = createFont(directory + "Light" + fileType, fontSize);
  fontWeightRegular = createFont(directory + "Regular" + fileType, fontSize);
  fontWeightBold = createFont(directory + "Bold" + fileType, fontSize);
}

PImage[] loadObjects(int res) {
  String directory = "/objects";

  File f = dataFile(directory);
  String[] names = f.list();

  PImage[] objs = new PImage[names.length];

  for (int i = 0; i < objs.length; i++) {
    String fileName = names[i];
    objs[i] = loadImage(directory + "/" + fileName);
    int w = objs[i].width;
    int h = objs[i].height;
    float aspectRatio = w / h;

    if (w >= h) {
      objs[i].resize(res, floor(res/aspectRatio));
    } else {
      objs[i].resize(floor(res*aspectRatio), res);
    }
  }

  return objs;
}

PVector[][] calculateGrid(int cells, float x, float y, float w, float h, float margin_min, float gutter_h, float gutter_v, boolean align_top) {
  int cols = 0, rows = 0;
  float cell_size = 0;
  while (cols * rows < cells) {
    cols += 1;
    cell_size = ((w - margin_min * 2) - (cols - 1) * gutter_h) / cols;
    rows = floor((h - margin_min * 2) / (cell_size + gutter_v));
  }
  if (cols * (rows - 1) >= cells) {
    rows -= 1;
  }
  float margin_hor_adjusted = ((w - cols * cell_size) - (cols - 1) * gutter_h) / 2;
  if (rows == 1 && cols > cells) {
    margin_hor_adjusted = ((w - cells * cell_size) - (cells - 1) * gutter_h) / 2;
  }
  float margin_ver_adjusted = ((h - rows * cell_size) - (rows - 1) * gutter_v) / 2;
  if (align_top) {
    margin_ver_adjusted = min(margin_hor_adjusted, margin_ver_adjusted);
  }
  PVector[][] positions = new PVector[rows][cols];
  for (int row = 0; row < rows; row++) {
    float row_y = y + margin_ver_adjusted + row * (cell_size + gutter_v);
    for (int col = 0; col < cols; col++) {
      float col_x = x + margin_hor_adjusted + col * (cell_size + gutter_h);
      positions[row][col] = new PVector(col_x, row_y, cell_size);
    }
  }
  return positions;
}

void calculateFontSizes() {
  fontSizeTiny = round(height / 108);
  fontSizeSmall = round(height / 67.5);
  fontSizeMedium = round(height / 45);
  fontSizeBig = round(height / 33.75);
  fontSizeHuge = round(height / 23.48);
}
