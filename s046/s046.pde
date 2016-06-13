void setup()
{
  //size(displayWidth, displayHeight);
  size(600, 600);
  //fullScreen();
  
  //colorMode(HSB, 360, 255, 255, 255);
  //blendMode(ADD);
  
  audioSetup();
  reset();
}

void prepare()
{
  prepareAnalysis();
  
  background(50);
  fill(0, 50);
  noStroke();
  for (int i = 0; i < 10; i++)
    rect(0, 0, width, height);
}

void executeDraw()
{
  resetBackground();
  
  noStroke();
  fill(255);
  
  debugDrawChannelPitch();
  //debugDrawChannelInstruments();
}

void resetBackground()
{
  fill(0, 50);
  noStroke();
  rect(0, 0, width, height);
  //background(0);
}