/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

float angleWidthMin = 0.01;
float angleWidthMax = 0.15;

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
  
  frameCount = 0;

  noiseSeed((int) random(10000));

  background(0);
  noStroke();

  drawCircle(width / 2, height / 2, min(width, height) / 2, (int) random(300, 700) * 3, random(1, 3));

/*
  float x = width / 2;
  float y = height / 2;
  for (int i = 0; i < 5; i++)
  {
    float border = 10;
    x = random(border, width - border);
    y = random(border, height - border);
    float maxRadius = min(x, width - x, min(y, height - y));
    //float maxRadius = 300;
    float radius = random(maxRadius / 2, maxRadius);
    drawCircle(x, y, radius, 5000);
    //ellipse(x, y, radius * 2, radius * 2);
*/
    /*
    float newX;
    float newY;
    do
    {
      float angle = random(0, PI * 2);
      newX = x + cos(angle) * radius;
      newY = y + sin(angle) * radius;
    } while ((newX < border) || (newY < border) ||
             (newX >= width - border) || (newY >= height - border));
    
    x = newX;
    y = newY;
    */
  //}
  //drawCircle(width / 2, height / 2, min(width, height) / 2, 5000); 
}

void drawCircle(float x, float y, float maxRadius, int count, float variation)
{
  pushMatrix();
  translate(x, y);
  
  float angleWidth = random(angleWidthMin, angleWidthMax);
  float colorMultiplier = random(0.1, 2);
  
  for (int i = 0; i < count; i++)
  {
    float radius1 = random(0, maxRadius);
    float radius2 = random(0, maxRadius);
    
    float angle1 = random(0, PI * 2);
    //float angle2 = angle1 + random(angleWidthMin, angleWidthMax);
    float angle2 = angle1 + angleWidth;
    
    float x1 = cos(angle1) + random(-variation, variation);
    float y1 = sin(angle1) + random(-variation, variation);
    float x2 = cos(angle2) + random(-variation, variation);
    float y2 = sin(angle2) + random(-variation, variation);
    
    //fill(random(100), 10);
    fill(noise(angle1 * colorMultiplier) * 100, 10);
    
    beginShape();
    vertex(x1 * radius1, y1 * radius1);
    vertex(x1 * radius2, y1 * radius2);
    vertex(x2 * radius2, y2 * radius2);
    vertex(x2 * radius1, y2 * radius1);
    endShape(CLOSE);
  }
  
  popMatrix();
}

void draw()
{
}

void mouseClicked()
{
  setup();
}
