int layers = 5;
int children = 3;
int lineLengthPerLayerMin = 10;
int lineLengthPerLayerMax = 60;
int seed;
float time;
float timeSpeed = 0.001;
int index;
int currentStep;
int stepCountMin = 500;
int stepCountMax = 1000;
int stepCount;
int stepsPerDraw = 10;
boolean instant = false;

float scale = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight, String mode)
{
  size(desiredWidth, desiredHeight, mode);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  scaledSize(500, 500, 500, 500, OPENGL);
  blendMode(ADD);
  
  seed = (int) random(100000);
  noiseSeed(seed);

  currentStep = 0;
  stepCount = (int) random(stepCountMin, stepCountMax);
  time = 0;

  background(0);
  if (instant)
  {
    for (int i = 0; i < stepCount; i++)
    {
      step();
    }
  }
  else
  {
    draw();
  }
}

void draw()
{
  if (currentStep >= stepCount)
    return;
  
  for (int i = 0; i < stepsPerDraw; i++)
  {
    step();
  }
}

void step()
{
  if (currentStep >= stepCount)
    return;
  
  currentStep++;
  
  randomSeed(seed);
  time += timeSpeed;
  
  index = 0;
  for (int i = 0; i < children; i++)
  {
    drawLine(layers, width / 2, height / 2);
  }
}

void drawLine(int layer, float x, float y)
{
  index++;
  
  float angle = noise(index, time) * PI * 2 * 10;
  float length = random(lineLengthPerLayerMin, lineLengthPerLayerMax) * layer * scale;
  float dx = cos(angle) * length;
  float dy = sin(angle) * length;
  float c = noise(index, time) * 255;
  
  strokeWeight(scale / 2);
  
  stroke(c, 5);
  line(x, y, dx + x, dy + y);
  
  if (layer > 2)
  {
    int childLayer = layer - 1;
    for (int i = 0; i < children; i++)
    {
      float d = random(1);
      drawLine(childLayer, x + dx * d, y + dy * d);
    }
  }
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    instant = false;
    setup();
  }
  else if (mouseButton == RIGHT)
  {
    instant = true;
    setup();
  }
}
