/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

float gapProbabilityMin = 0;
float gapProbabilityMax = 0.8;
float minPointCount = 3;
float maxPointCount = 8;
float stepSizeMin = 1;
float stepSizeMax = 10;
float alphaStrokeMin = 0;
float alphaStrokeMax = 150;
float alphaFillMin = 5;
float alphaFillMax = 30;
float baseOffsetMultiplierMin = 0.001;
float baseOffsetMultiplierMax = 0.1;

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

  translate(width / 2, height / 2);
  
  do
  {
    noiseSeed((int)random(100000));
  } while (!execute());
}

void draw()
{
}

boolean execute()
{
  background(0);
  stroke(255, random(alphaStrokeMin, alphaStrokeMax));
  fill(255, random(alphaFillMin, alphaFillMax));
  
  boolean drewSomething = false;
  
  float stepSize = random(stepSizeMin, stepSizeMax);
  float gapProbability = random(gapProbabilityMin, gapProbabilityMax);
  float baseOffsetMultiplier = random(baseOffsetMultiplierMin, baseOffsetMultiplierMax);
  
  for (float distance = stepSize; distance < width / 2; distance += stepSize)
  {
    float baseOffset = distance * baseOffsetMultiplier;
    if (noise(baseOffset, 0) <= gapProbability)
      continue;
    
    drewSomething = true;
    
    float startAngle = noise(baseOffset, 10) * PI * 2;
    int pointCount = round(lerp(minPointCount, maxPointCount, noise(baseOffset, 20)));
    float angleDelta = PI * 2 / pointCount;
    
    //stroke(255, lerp(alphaStrokeMin, alphaStrokeMax, noise(baseOffset, 30)));
    //fill(255, lerp(alphaFillMin, alphaFillMax, noise(baseOffset, 40)));
    
    beginShape();
    for (int i = 0; i < pointCount; i++)
    {
      float angle = startAngle + angleDelta * i;
      float x = cos(angle) * distance;
      float y = sin(angle) * distance;
      //stroke(255, lerp(alphaStrokeMin, alphaStrokeMax, noise(baseOffset, 30, i)));
      //fill(255, lerp(alphaFillMin, alphaFillMax, noise(baseOffset, 40, i)));
      vertex(x, y);
      //ellipse(x, y, 10, 10);
    }
    endShape(CLOSE);
  }
  
  return drewSomething;
}

void mousePressed()
{
  setup();
}
