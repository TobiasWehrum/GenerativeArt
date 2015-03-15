/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

int startingBlobCount = 15;
int speed = 1000;
int scale = 5;
int scaledWidth;
int scaledHeight;

ArrayList<Integer> filledPixels = new ArrayList<Integer>();
ArrayList<Integer> freeNeighbors = new ArrayList<Integer>();
color[] pixelColors;

void setup()
{
  size(500, 500, OPENGL);
  colorMode(HSB, 255);
  noSmooth();
  noFill();
  noStroke();
  
  scaledWidth = width / scale;
  scaledHeight = height / scale;
  
  pixelColors = new color[scaledWidth*scaledHeight];
  
  background(0, 0, 255);
  
  filledPixels.clear();
  for (int i = 0; i < startingBlobCount; i++)
  {
    int x = (int) random(scaledWidth);
    int y = (int) random(scaledHeight);
    float h = random(255);
    drawPixel(x, y, h, 255, 255);
  }
}

void draw()
{
  for (int i = 0; i < speed; i++)
  {
    step();
  }
}

void step()
{
  int targetX = 0, targetY = 0, index = 0;
  boolean neighborUsed = freeNeighbors.size() > 0;
  //if (neighborUsed)
    //if (random(1) < 0.8)
      neighborUsed = false;
  
  if (neighborUsed)
  {
    int freeNeighborIndex = (int) random(freeNeighbors.size());
    int targetIndex = freeNeighbors.get(freeNeighborIndex);
    freeNeighbors.remove(freeNeighborIndex);
  
    targetX = (int)(targetIndex / scaledWidth);
    targetY = targetIndex % scaledWidth;
  
    index = findFilledNeighborIndex(targetX, targetY);
  }
  else
  {
    int filledPixelIndex = (int) random(filledPixels.size());
    index = filledPixels.get(filledPixelIndex);
  }
  
  int x = (int)(index / scaledWidth);
  int y = index % scaledWidth;
  
  //println(x + "|" + y + " <- " + targetX + "|" + targetY);
  
  color c = pixelColors[index];
  float h = hue(c);
  float s = saturation(c);
  float b = brightness(c);
  
  int stepSize = 10;
  float noiseIndexByIndex = index + frameCount * 0.01;
  float noiseIndexByHue = h + frameCount * 0.01;// + x * 0.1 + y * 0.1;
  
  s = min(max(s + round(lerp(-stepSize, stepSize, noise(noiseIndexByIndex, 10))), 0), 255);
  b = min(max(b + round(lerp(-stepSize, stepSize, noise(noiseIndexByIndex, 20))), 0), 255);
  
  if (!neighborUsed)
  {
    targetX = x;
    targetY = y;
    if (random(1) <= 0.5)
      targetX += (random(1) <= 0.5) ? -1 : 1;
    else
      targetY += (random(1) <= 0.5) ? -1 : 1;
  
/*  
    float dx = (noise(noiseIndexByHue / 10, 10) * 10) % 1 * 2 - 1;
    float dy = (noise(noiseIndexByHue / 10, 20) * 10) % 1 * 2 - 1;
    
    if (abs(dx) > abs(dy))
    {
      dy = 0;
    }
    else
    {
      dx = 0;
    }
    
    targetX = x + round(dx);
    targetY = y + round(dy);
*/
      
    if (targetX < 0) targetX = 0;
    if (targetX >= scaledWidth) targetX = scaledWidth - 1;
    if (targetY < 0) targetY = 0;
    if (targetY >= scaledHeight) targetY = scaledHeight - 1;
  }
  
  drawPixel(targetX, targetY, h, s, b);
}

void drawPixel(int x, int y, float h, float s, float b)
{
    int p = x * scaledHeight + y;
    if (!filledPixels.contains(p))
      filledPixels.add(p);
      
    //stroke(h, s, b, 10);
    fill(h, s, b, 10);
    pixelColors[p] = color(h, s, b);
    //point(x, y);
    rect(x * scale, y * scale, scale, scale);
    //ellipse(x * scale, y * scale, scale * 2, scale * 2);
    
    //addNeighborIfFree(x + 1, y);
    //addNeighborIfFree(x - 1, y);
    //addNeighborIfFree(x, y + 1);
    //addNeighborIfFree(x, y - 1);
}

void addNeighborIfFree(int x, int y)
{
  if (x < 0) return;
  if (y < 0) return;
  if (x >= scaledWidth) return;
  if (y >= scaledHeight) return;
  
  int index = x * scaledHeight + y;
  if (!filledPixels.contains(index) && !freeNeighbors.contains(index))
  {
    freeNeighbors.add(index);
  }
}

ArrayList<Integer> tempList = new ArrayList<Integer>();

int findFilledNeighborIndex(int x, int y)
{
  tempList.clear();
  int index = x * scaledHeight + y;
  
  if (filledPixels.contains(index + 1) && ((y + 1) < scaledHeight))
    tempList.add(index + 1);
    
  if (filledPixels.contains(index - 1) && (y > 0))
    tempList.add(index - 1);
  
  if (filledPixels.contains(index + scaledWidth) && ((x + 1) < scaledWidth))
    tempList.add(index + scaledWidth);

  if (filledPixels.contains(index - scaledWidth) && (x > 0))
    tempList.add(index - scaledWidth);
    
  int i = (int)random(tempList.size());
  return tempList.get(i);
}

void mouseClicked()
{
  setup();
}
