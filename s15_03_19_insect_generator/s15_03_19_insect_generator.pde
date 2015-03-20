/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh (and increase alien glitch)
- Right-click to refresh (and reset alien glitch)
- Mouse-wheel or +/-: Cycle through coloring options
*/

int clickCount = 0;
int seed = 0;

int mode = 0;
int modeCount = 3;

void setup()
{
  size(1000, 1000);
  colorMode(HSB, 255);
  smooth();
  
  seed = (int) random(10000);
  
  redraw();
}

void redraw()
{
  int diameter = 500;
  int countX = width / diameter;
  int countY = height / diameter;
  
  int startX = floor((width / 2.0) - (countX / 2.0) * diameter + diameter / 2.0);
  int startY = floor((height / 2.0) - (countY / 2.0) * diameter + diameter / 2.0);
  
  randomSeed(seed);
  
  background(0);
  for (int x = 0; x < countX; x++)
  {
    for (int y = 0; y < countY; y++)
    {
      noiseSeed(seed + x + y * countX);
      float noiseMultiplier = random(2, 5);
  
      //float centerX = width / 2;
      //float centerY = height / 2;
      //float radius = min(width, height) / 2;
      int centerX = startX + x * diameter;
      int centerY = startY + y * diameter;
      int radius = diameter / 2;
      
      drawInsect(centerX, centerY, radius, noiseMultiplier);
    }
  }
}

void drawInsect(int centerX, int centerY, int maxRadius, float noiseMultiplier)
{
  pushMatrix();
  translate(centerX, centerY);
  
  stroke(255);
  fill(255);
  
  float pointCount = 200;
  float angleDelta = PI * 2 / pointCount;
  
  float halfPointCount = pointCount / 2;
  
  float weird = random(clickCount * 0.1);
  
  beginShape();
  for (int i = 0; i < pointCount; i++)
  {
    //float ppI = pointCount / 2 - abs(i - pointCount / 2);
    //float ppI = (i < halfPointCount) ? i : (pointCount - i);
    
    float angle = i * angleDelta;
    float ppA = (angle < PI) ? angle : PI * 2 - angle;
    float radius = noise(ppA * noiseMultiplier, 10) * maxRadius;
    
    //noStroke();
    //fill((noise(ppA * 0.1) * 2550) % 255, 255, 255);
    
    float angleOffset = -PI / 2;
    
    angleOffset += ((angle < PI) ? 1 : -1) * noise(radius * 0.5, 20) * weird;
    
    float x = cos(angle + angleOffset) * radius;
    float y = sin(angle + angleOffset) * radius;
    
    vertex(x, y);
  }
  endShape(CLOSE);
  
  //blendMode(DARKEST);
  
  loadPixels();
  color bgColor = color(0);
  float fillHue = random(0, 255);
  float hueFactor = 0.001;
  float saturationFactor = 0.001;
  float brightnessFactor = 0.008;
  for (int x = -maxRadius + 1; x <= 0; x++)
  {
    for (int y = -maxRadius + 1; y < maxRadius; y++)
    {
      int px = centerX + x;
      int py = centerY + y;
      int pi = px + py * width;
      
      if (mode != 2)
      {
        if (pixels[pi] != bgColor)
        {
          float pixelBrightness = brightness(pixels[pi]);
          //fillHue = (noise(x * hueFactor, py * hueFactor, 10) * 2550) % 255;
          float fillSaturation = (noise(x * saturationFactor, py * saturationFactor, 20) * 255) % 255;
          fillSaturation = 255;
          float fillBrightness = pixelBrightness - noise(x * brightnessFactor, py * brightnessFactor, 30) * 255;
          
          if (mode == 1)
          {
            fillSaturation = 0;
          }
          
          pixels[pi] = color(fillHue, fillSaturation, fillBrightness);
        }
      }

      int pi2 = centerX - x + py * width;
      pixels[pi2] = pixels[pi];
    }
  }
  updatePixels();
  
  //blendMode(NORMAL);
  
  popMatrix();
}

void draw()
{
  redraw();
}

void mouseWheel(MouseEvent event)
{
  //clickCount += event.getCount();
  //redraw();
  //setup();
  
  mode = (mode - event.getCount() + modeCount) % modeCount;
}

void keyPressed()
{
  if (key == '+')
  {
    mode = (mode + 1) % modeCount;
  }
  else if (key == '-')
  {
    mode = (mode - 1 + modeCount) % modeCount;
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    clickCount++;
    setup();
  }
  else if (mouseButton == RIGHT)
  {
    clickCount = 0;
    setup();
  }
}


  /*
  float eyeRadius = 10f;
  float eyeAngle = 0.5f;
  float eyeCheckRange = 0.1f;
  //float eyeCheckResolution = 10;
  //float eyeCheckDelta = eyeCheckRange / eyeCheckResolution;
  drawEye(eyeAngle, eyeRadius);
  drawEye(-eyeAngle, eyeRadius);
  
void drawEye(float angle, float radius)
{
  PVector position = getPosition(angle); 
  
  strokeWeight(2);
  stroke(0);
  fill(255);
  
  ellipse(position.x / 2, position.y / 2, radius * 2, radius * 2);
}
  */

