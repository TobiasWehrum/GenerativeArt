/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click or X to refresh.
- Right-click or C to refresh, but keep color palette.
- Middle-click or V to refresh, but switch colors.
*/

color landColor;
color waterColor;

void setup()
{
  //size(500, 500, P2D);
  size(displayWidth, displayHeight, P2D);
  colorMode(HSB, 360, 1, 1, 1);
  blendMode(ADD);
  
  refresh(true);
}

void refresh(boolean refreshColors)
{
  noiseSeed((int) random(1000000));

  if (refreshColors)
  {
    float landBrightness = random(1);
    float waterBrightness = random(1);
    
    if (landBrightness < waterBrightness)
    {
      float t = landBrightness;
      landBrightness = waterBrightness;
      waterBrightness = t;
    }
    
    landColor = color(random(360), sqrt(random(0.1, 1)), landBrightness, 0.5);
    waterColor = color(random(360), sqrt(random(0.1, 1)), waterBrightness, 0.5);
  }

  background(0);
  
  ArrayList<Point> points = createPoints();
  connectPoints(points);
}

ArrayList<Point> createPoints()
{
  ArrayList<Point> points = new ArrayList<Point>();
  float distance = 15;
  
  float positionNoise = 5;
  
  float noiseScale = 0.01 * (500.0/displayWidth) * random(0.5, 2.5);
  float landHeight = random(0.55, 0.65);
  
  int extraPadding = 5;
  float startX = -distance / 2 - distance * extraPadding;
  float startY = startX;
  float endX = width + distance * (extraPadding + 1);
  float endY = height + distance * (extraPadding + 1);
  for (float x = startX; x < endX; x += distance)
  {
    for (float y = startY; y < endY; y += distance)
    {
      Point p = new Point();
      p.x = x + random(-positionNoise, positionNoise);
      p.y = y + random(-positionNoise, positionNoise);
      p.h = noise(x * noiseScale, y * noiseScale);
      p.land = p.h >= landHeight;
      p.c = p.land ? landColor : waterColor;
      //p.c = color(0, 0, p.h, 1);
      points.add(p);
    }
  }
  return points;
}

void connectPoints(ArrayList<Point> points)
{
  float maxDistance = 100;
  
  float pointCount = points.size();
  for (int i = 0; i < pointCount; i++)
  {
    Point a = points.get(i);
    for (int j = i + 1; j < pointCount; j++)
    {
      Point b = points.get(j);
      if (a.land != b.land)
        continue;
        
      if ((abs(a.x - b.x) > maxDistance) || (abs(a.y - b.y) > maxDistance))
        continue;
      
      float distance = dist(a.x, a.y, b.x, b.y);
      if (distance > maxDistance)
        continue;
        
      float closeness = 1 - (distance / maxDistance);
      stroke(a.c, closeness);
      line(a.x, a.y, b.x, b.y);
    }
    /*
    stroke(a.c);
    noFill();
    ellipse(point.x, point.y, 5, 5);
    */
  }
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

void draw()
{
}

void keyPressed()
{
  if (key == 'x')
  {
    refresh(true);
  }
  else if (key == 'c')
  {
    refresh(false);
  }
  else if (key == 'v')
  {
    color temp = landColor;
    landColor = waterColor;
    waterColor = temp;
    refresh(false);
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    refresh(true);
  }
  else if (mouseButton == RIGHT)
  {
    refresh(false);
  }
  else if (mouseButton == CENTER)
  {
    color temp = landColor;
    landColor = waterColor;
    waterColor = temp;
    refresh(false);
  }
}

class Point
{
  float x;
  float y;
  float h;
  boolean land;
  color c;
}
