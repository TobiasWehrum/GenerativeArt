/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to refresh, but keep colors.
*/

int seed;
color startColor;
color endColor;

float scale = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  scaledSize(500, 500, displayWidth, displayHeight);
  //size(500, 500);
  smooth();
  colorMode(HSB, 255);
  
  reset(true);
}

void reset(boolean chooseColor)
{
  seed = (int) random(100000) + frameCount;
  noiseSeed(seed);
  
  if (chooseColor)
  {
    float startHue = random(0, 255);
    //float endHue = startHue + 50 * random(-1, 1);
    float endHue = random(0, 255);
    startColor = color(startHue, 255, 255);
    endColor = color(endHue, random(50, 255), random(0, 255));
   // endColor = color(endHue, random(50, 255), random(0, 150));
  }
  
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
  color centerColor = lerpColor(startColor, endColor, centerColorPosition);
  
  //color strokeColor = color(random(1) < 0.5 ? 0 : 255, 50);
  color strokeColor = color(255, 50);
  
  float deltaAngle = PI * 2 / circleSteps;
  float startAngle = random(0, deltaAngle);
  float previousX = 0;
  float previousY = 0;
  for (int i = 0; i <= circleSteps; i++)
  {
    float angle = startAngle + i * deltaAngle;
    float x = centerX + cos(angle) * circleRadius;
    float y = centerY + sin(angle) * circleRadius;
    
    if (i > 0)
    {
      float tentacleX = (previousX + x) / 2;
      float tentacleY = (previousY + y) / 2; 
      float tentacleAngle = startAngle + (i - 0.5) * deltaAngle;
      float tentacleWidth = dist(x, y, previousX, previousY) / 2;
      float fullAngle = random(-1, 1) * PI * 1.5;
      float fullLength = random(50, 300) * scale;
      drawTentacle(tentacleX, tentacleY, tentacleAngle, tentacleWidth, fullAngle, fullLength, centerColor, endColor, strokeColor);
    }
    
    previousX = x;
    previousY = y;
  }

  stroke(strokeColor);
  for (int i = centerFillStepCount; i >= 1 ; i--)
  {
    float t = (float)i / centerFillStepCount;
    color currentColor = lerpColor(startColor, centerColor, t);
    fill(currentColor);
    ellipse(centerX, centerY, circleRadius * 2 * t, circleRadius * 2 * t);
    //stroke(255, 50);
  }
  
  //fill(startColor);
  //ellipse(centerX, centerY, circleRadius * 2, circleRadius * 2);
  
/*
  beginShape();
  for (int i = 0; i <= 10 * extraSteps; i++)
  {
    float angle = startAngle + i * deltaAngle / extraSteps;
    float x = centerX + cos(angle) * circleRadius;
    float y = centerY + sin(angle) * circleRadius;
    vertex(x, y);
  }
  endShape();
*/
  
  //drawTentacle(width / 2, height, -PI/2);
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
  if (mouseButton == LEFT)
  {
    reset(true);
  }
  else if (mouseButton == RIGHT)
  {
    reset(false);
  }
}

