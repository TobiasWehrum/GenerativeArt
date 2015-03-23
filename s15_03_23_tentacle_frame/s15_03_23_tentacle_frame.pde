/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

int seed;

float scale = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  int side = 500;
  //float side = min(displayWidth, displayHeight);
  scaledSize(500, 500, side, side);
  smooth();
  colorMode(HSB, 255);
  reset();
}

void reset()
{
  seed = (int) random(100000);
  noiseSeed(seed);
  execute();
}

void draw()
{
}

void execute()
{
  randomSeed(seed);
  
  background(0);

  float centerX = width / 2;
  float centerY = height / 2;
  int circleSteps = 10;
  float circleRadius = 70 * scale;
  //int extraSteps = 4;
  
  int centerFillStepCount = 3;
  float centerColorPosition = 0.3;
  
  //float hue = 170;
  //color centerColor = lerpColor(startColor, endColor, centerColorPosition);
  
  //color strokeColor = color(random(1) < 0.5 ? 0 : 255, 50);
  
  float stepSizeX = 50;
  int stepCountX = (int)(width / stepSizeX);
  stepSizeX = (float)width / stepCountX;
  
  float stepSizeY = 50;
  int stepCountY = (int)(height / stepSizeY);
  stepSizeY = (float)height / stepCountY;
  
  /*
  for (int step = 0; step < stepCountX; step++)
  {
    float x = (step + 0.5) * stepSizeX;
    drawTentacle(x, height, -PI/2, stepSizeX, startColor, endColor, strokeColor);
    drawTentacle(x, 0, PI/2, stepSizeX, startColor, endColor, strokeColor);
  }
  for (int step = 0; step < stepCountY; step++)
  {
    float y = (step + 0.5) * stepSizeY;
    drawTentacle(0, y, 0, stepSizeY, startColor, endColor, strokeColor);
    drawTentacle(width, y, PI, stepSizeY, startColor, endColor, strokeColor);
  }
  */
  
  float radius = dist(0, 0, width/2, height/2);
  int count = 200;
  for (int i = 1; i <= count; i++)
  {
    float angle = random(0, PI * 2);
    float x = width/2 + cos(angle) * radius;
    float y = height/2 + sin(angle) * radius;
    drawTentacle(x, y, angle - PI, 50, (float)i / count);
  }
}

void drawTentacle(float x, float y, float angle, float fullWidth, float t)
{
    float fullAngle = random(-1, 1) * PI * 1.5;
    float fullLength = random(100, 500) * scale;
    
    //float s = 0.0001;
    //float sx = x * s;
    //float sy = y * s;
    float sa = angle * 0.01; 
    float startHue = lerp(0, 255, (noise(sa, 0) * 10) % 1);
    float endHue = lerp(0, 255, (noise(sa, 10) * 10) % 1);
    color strokeColor = color(255, 50 * pow(t, 4));
    color startColor = color(startHue, 255, 255 * pow(t, 4));
    color endColor = color(endHue, random(50, 255), random(0, 255) * pow(t, 4));
    
    drawTentacle(x, y, angle, fullWidth, fullAngle, fullLength, startColor, endColor, strokeColor);
}

void drawTentacle(float x, float y, float angle, float fullWidth, float fullAngle, float fullLength,
                  color startColor, color endColor, color strokeColor)
{
  //stroke(120);
  //fill(120);
  
  float stepPerLength = 10 * scale;
  int stepCount = max((int)(fullLength / stepPerLength), 10);
  
  float deltaAngle = fullAngle / stepCount;
  float deltaLength = fullLength / stepCount;
  
  float previousX1 = 0;
  float previousX2 = 0;
  float previousY1 = 0;
  float previousY2 = 0;
  
  //ArrayList<PVector> points = new ArrayList<PVector>();
  for (int i = 0; i < stepCount; i++)
  {
    float t = (float)i / (stepCount - 1);
    float iT = 1 - t;
    
    float currentWidth = iT * fullWidth;
    float deltaX = cos(angle);
    float deltaY = sin(angle);
    
    float currentX1 = x + deltaY * currentWidth;
    float currentY1 = y - deltaX * currentWidth;
    float currentX2 = x - deltaY * currentWidth;
    float currentY2 = y + deltaX * currentWidth;
    
    if (i > 0)
    {
      //fill(hue + t * 120, (1 - t) * 120 + 135, 255);
      color currentColor = lerpColor(startColor, endColor, t);
      fill(currentColor);
      stroke(currentColor);
      beginShape();
      vertex(currentX1, currentY1);
      vertex(currentX2, currentY2);
      vertex(previousX2, previousY2);
      vertex(previousX1, previousY1);
      endShape(CLOSE);
      
      noFill();
      stroke(strokeColor);
      beginShape();
      vertex(currentX1, currentY1);
      vertex(currentX2, currentY2);
      vertex(previousX2, previousY2);
      vertex(previousX1, previousY1);
      endShape(CLOSE);
    }
    
    previousX1 = currentX1;
    previousX2 = currentX2;
    previousY1 = currentY1;
    previousY2 = currentY2;
    angle += deltaAngle;
    x += deltaX * deltaLength;
    y += deltaY * deltaLength;
  }
}

void mouseClicked()
{
  reset();
}

