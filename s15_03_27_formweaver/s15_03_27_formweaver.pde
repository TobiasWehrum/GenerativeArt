PVector[] points;
float t;
int offset;
color fillColor;
color strokeColor;

void setup()
{
  size(500, 500, OPENGL);
  blendMode(ADD);
  colorMode(HSB, 255);
  
  noStroke();
  noFill();
  
  refresh();
}

void refresh()
{
  background(0);
  
  t = 0;
  offset = 1;
  
  points = new PVector[(int)random(random(3, 5), 8)];
  points[0] = getRandomPoint();
  for (int i = 1; i < points.length; i++)
  {
    float highestCumulativeDistance = 0;
    for (int j = 0; j < 5; j++)
    {
      PVector newPoint = getRandomPoint();
      float newCumulativeDistance = cumulativeDistance(i, newPoint);
      if (newCumulativeDistance >= highestCumulativeDistance)
      {
        points[i] = newPoint;
        highestCumulativeDistance = newCumulativeDistance;
      }
    }
  }

  pickColor();
}

PVector getRandomPoint()
{
  return new PVector(random(width), random(height));
}

float cumulativeDistance(int count, PVector referencePoint)
{
  float distance = 1;
  for (int i = 0; i < count; i++)
  {
    distance *= points[i].dist(referencePoint);
  }
  return distance;
}

void pickColor()
{
  fillColor = color(random(255), 255, 255);
  strokeColor = fillColor;
}

void draw()
{
  step();
}

boolean step()
{
  if (t >= 1)
    return true;
    
  t += 0.01;
  if (t >= 1)
  {
    t = 0;
    do
    {
      //shiftPoints();
      
      offset++;
      if (offset == points.length)
      {
        t = 1;
        return true;
      }
    } while (random(1) > 0.5);
    //return true;
  }
  
  stroke(strokeColor, 10 - points.length);
  fill(fillColor, 1);
  
  beginShape();
  for (int i = 0; i < points.length; i++)
  {
    PVector a = points[i];
    PVector b = points[(i + offset) % points.length];
    float x = lerp(a.x, b.x, t % 1);
    float y = lerp(a.y, b.y, t % 1);
    vertex(x, y);
  }
  endShape(CLOSE);
  return false;
}

void shiftPoints()
{
      PVector[] newPoints = new PVector[points.length];
      for (int i = 0; i < points.length; i++)
      {
        PVector a = points[i];
        PVector b = points[(i + 1) % points.length];
        float x = lerp(a.x, b.x, 0.5);
        float y = lerp(a.y, b.y, 0.5);
        newPoints[i] = new PVector(x, y);
      }
      points = newPoints;
}

void mouseClicked()
{
  refresh();
  if (mouseButton == RIGHT)
  {
    while (!step())
    {
    }
  }
}
