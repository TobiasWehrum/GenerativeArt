/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

float hueBase = 0;

float scale = 1;
float scaleWidth = 1;
int seed = 0;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight, String mode)
{
  size(desiredWidth, desiredHeight, mode);
  scale = (float)desiredHeight / originalHeight;
  scaleWidth = (float)desiredWidth / originalWidth;
}
/*
void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}
*/

void setup()
{
  scaledSize(1000, 720, displayWidth, displayHeight, P2D);
  scale *= 0.5;
  colorMode(HSB, 255);
  smooth();
 
  background(0);
 
  restart();
}

void restart()
{
  seed = (int) random(100000);
  hueBase = random(0, 255);
  redraw();
}

void draw()
{
}

void redraw()
{
  randomSeed(seed);
  noiseSeed((int) random(100000));
 
  background(0);
  
  float borderX = 100 * scale;
  float borderY = 10 * scale;
  
  int fireflyCount = (int) random(1, 3);
  
  int treeCount = (int)(random(10, 200) * scaleWidth);
  for (int i = 1; i <= treeCount; i++)
  {
    float z = pow((float)i / treeCount, 4);
    float rootY = lerp(height / 10, height - borderY, z);
    float distanceScale = scale * z;
    drawFloor(rootY, z, distanceScale);
  }
  
  for (int i = 1; i <= treeCount; i++)
  {
    float z = pow((float)i / treeCount, 4);
    float rootX = random(borderX, width - borderX);
    float rootY = lerp(height / 10, height - borderY, z);
    float distanceScale = scale * z;
  
    drawTree(z, rootX, rootY, distanceScale);
    
//    drawFloor(rootY, z, distanceScale);
    drawFireflies(rootY, z, distanceScale, fireflyCount);
  }
}

void drawTree(float z, float rootX, float rootY, float distanceScale)
{
  ArrayList<PVector> points = new ArrayList<PVector>();
  ArrayList<PVector> endPoints = new ArrayList<PVector>();
  
  int startLayer = 1;
  float treeWidth = getWidth(startLayer) * distanceScale;
  constructTreeRecursive(new PVector(rootX - treeWidth / 2, rootY),
                         new PVector(rootX + treeWidth / 2, rootY),
                         0, startLayer, points, 0, endPoints, distanceScale);
                    
  //stroke(0, 50);
  noStroke();
  fill(20 * z);
  beginShape();
  for (PVector p : points)
  {
    fill(hueBase, random(0, 255), 20 * z * random(0, 1));
    vertex(p.x, p.y);
    //println(p.x, p.y);
  }
  endShape(CLOSE);
  
  for (PVector p : endPoints)
  {
    drawLampion(p.x, p.y, z, distanceScale);
  }
}

int constructTreeRecursive(PVector left, PVector right, int angleDirectionToTop, int layer, ArrayList<PVector> points,
                          int pointsStartIndex, ArrayList<PVector> endPoints, float distanceScale)
{
  if (layer > maxLayer)
    return 0;
  
  int pointsAdded = 3;
  
  float angle = getBaseAngle(left, right) + getAngleDiff(layer, angleDirectionToTop);
  float partLength = getLength(layer) * distanceScale;
  
  PVector center = PVector.div(PVector.add(left, right), 2);
  PVector direction = new PVector(cos(angle) * partLength, sin(angle) * partLength);
  PVector top = PVector.add(center, direction);
  points.add(pointsStartIndex, left);
  points.add(pointsStartIndex + 1, top);
  points.add(pointsStartIndex + 2, right);
  
  if (layer < maxLayer)
  {
    boolean extendLeft = random(1) < 0.5;
    boolean extendRight = !extendLeft;
    
    if (layer == 1)
    {
      extendLeft = true;
      extendRight = true;
    }  
    
    if (extendLeft)
    {
      pointsAdded += addTreePart(left, top, true, layer + 1, points, pointsStartIndex + 1, endPoints, distanceScale);
    }
    
    if (extendRight)
    {
      pointsAdded += addTreePart(top, right, false, layer + 1, points, pointsStartIndex + pointsAdded - 1, endPoints, distanceScale);
    }
  }
  
  if ((layer == 1) || (layer == maxLayer))
  {
    endPoints.add(top);
  }
  
  return pointsAdded;
}

int addTreePart(PVector left, PVector right, boolean rightTop, int layer, ArrayList<PVector> points, int pointsStartIndex,
                ArrayList<PVector> endPoints, float distanceScale)
{
  float partWidth = getWidth(layer) * distanceScale;
  PVector delta = PVector.sub(right, left);
  float distance = delta.mag();
  PVector direction = PVector.div(delta, distance);
  if (delta.mag() > partWidth)
  {
    left = new PVector(left.x, left.y);
    right = new PVector(right.x - direction.x * partWidth, right.y - direction.y * partWidth);
    float t = getBranchPosition(layer);
    if (!rightTop)
    {
      t = 1 - t;
    }
    float xStart = lerp(left.x, right.x, t);
    float yStart = lerp(left.y, right.y, t);
    left.x = xStart;
    left.y = yStart;
    right.x = left.x + direction.x * partWidth;
    right.y = left.y + direction.y * partWidth;
  }
  
  return constructTreeRecursive(left, right, rightTop ? 1 : -1, layer, points, pointsStartIndex, endPoints, distanceScale);
}

int maxLayer = 4;

float getWidth(int layer)
{
  return random(40, 60) / layer;
}

float getLength(int layer)
{
  return random(200, 400) / (((layer - 1) * 2) + 1);
}

float getAngleDiff(int layer, int angleDirectionToTop)
{
  if (angleDirectionToTop == 0)
  {
    return 0.2 * random(-1, 1);
  }
  
  return angleDirectionToTop * random(0.5, 1);
}

float getBranchPosition(int layer)
{
  return random(0.5, 0.7);
}

float getBaseAngle(PVector from, PVector to)
{
  return atan2(to.y - from.y, to.x - from.x) - PI / 2;
}

void drawLampion(float x, float y, float z, float distanceScale)
{
  blendMode(ADD);
  float diameter = distanceScale * 65;
  
  noStroke();
  /*
  int iterations = 1;
  for (int i = iterations - 1; i >= 0; i--)
  {
    float t = (float)i / iterations;
    float iT = 1 - t;
    fill(42, 255, sqrt(iT) * z * 255, sqrt(iT) * 255);
    ellipse(x, y, diameter + i, diameter + i);
  }
  */
  
  float hueVariation = 10;
  float saturationVaration = 10;
  float brightnessVariation = 10;
  float hue = (hueBase + random(-hueVariation, hueVariation)) % 255;
  float saturation = 255 + random(-saturationVaration, 0);
  float brightness = (100 + random(-brightnessVariation, brightnessVariation)) * sqrt(z);
  
  color cs = color(hue, saturation, brightness, 150);
  color c = color(hue, saturation, brightness, 150);
  color c1 = color(hue, saturation, brightness, 150);
  color c2 = color(hue, saturation, brightness, 0);
  
  fill(cs);
  ellipse(x, y, diameter / 4, diameter / 4);
  
  fill(c);
  int iterations = 2;
  for (int i = 0; i < iterations; i++)
  {
    float add = pow(i + 4, 2) * scale;
    ellipse(x, y, diameter + add, diameter + add);
  }
  
  strokeWeight(2);

  float lineOffset = (diameter + pow(0 + 4, 2) * scale) / 2; 
  
  int maxLineCount = (int)random(5, 8);
  float delta = PI * 2 / maxLineCount;
  float startAngle = random(0, PI * 2);
  for (int i = 0; i < maxLineCount; i++)
  {
    if (random(1) > 0.72)
      continue;
    
    float angle = startAngle + i * delta + (random(-1, 1) * delta / 2);
    float lineLength = random(70, 100) * distanceScale + lineOffset;
    float dx = cos(angle);
    float dy = sin(angle);
    gradientLine(x + dx * lineOffset, y + dy * lineOffset, x + dx * lineLength, y + dy * lineLength, c1, c2);
  } 

  blendMode(BLEND);
}

void gradientLine(float x1, float y1, float x2, float y2, color a, color b) {
  float deltaX = x2-x1;
  float deltaY = y2-y1;
  float tStep = 1.0/dist(x1, y1, x2, y2);
  for (float t = 0.0; t < 1.0; t += tStep) {
    fill(lerpColor(a, b, pow(t, 0.1)));
    ellipse(x1+t*deltaX, y1+t*deltaY, 3, 3);
  }
}

void drawFloor(float rootY, float z, float distanceScale)
{
  float diameter = 10 * distanceScale;
  
  noStroke();
  fill(hueBase, 0, 5 * z);
  
  for (float i = 0; i < 50; i++)
  {
    float x = random(0, width);
    float y = rootY + random(-10, 10) * distanceScale;
    ellipse(x, y, diameter, diameter);
  }
}

void drawFireflies(float rootY, float z, float distanceScale, int fireflyCount)
{
  blendMode(ADD);
  
  float diameter = 4 * distanceScale;
  float add = 10 * distanceScale;
  
  noStroke();
  
  for (int i = 0; i < fireflyCount; i++)
  {
    float x = random(0, width);
    float y = rootY - random(100, 400) * distanceScale;
    
    //x += noise(i, frameCount * 0.1, 10) * distanceScale * 100;
    //y += noise(i, frameCount * 0.1, 20) * distanceScale * 100;
    
    /*
    for (int o = 0; o < 4; o++)
    {
      float ox = noise(i, o * 0.01, 10) * distanceScale * 5;
      float oy = noise(i, o * 0.01, 20) * distanceScale * 5;
      
      stroke(0, 0, 255 * z, 150 * z * (o / 4.0));
      ellipse(x + ox, y + ox, diameter / (o + 1), diameter / (o + 1));
    }
    */
    
    fill(0, 0, 255 * z, 150 * z);
    ellipse(x, y, diameter, diameter);
    fill(0, 0, 150 * z, 50 * z);
    ellipse(x, y, diameter + 10, diameter + 10);
  }
  
  blendMode(BLEND);
}

void mouseClicked()
{
  restart();
}

class TreeLine
{
  
}
