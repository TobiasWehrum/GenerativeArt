/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to pause/resume.

Color schemes:
- "(◕ ” ◕)" by sugar!: http://www.colourlovers.com/palette/848743
- "vivacious" by plch: http://www.colourlovers.com/palette/557539/vivacious
- "Sweet Lolly" by nekoyo: http://www.colourlovers.com/palette/56122/Sweet_Lolly
- "Pop Is Everything" by jen_savage: http://www.colourlovers.com/palette/7315/Pop_Is_Everything
- "it's raining love" by tvr: http://www.colourlovers.com/palette/845564/its_raining_love
- "A Dream in Color" by madmod001: http://www.colourlovers.com/palette/871636/A_Dream_in_Color
- "Influenza" by Miaka: http://www.colourlovers.com/palette/301154/Influenza
- "Ocean Five" by DESIGNJUNKEE: http://www.colourlovers.com/palette/1473/Ocean_Five
*/

boolean useGradient = true;
String gradientFilename = "gradient_PopIsEverything.png";
String[] gradientFilenames = new String[] {
                                "gradient_HymnForMySoul.png",
                                "gradient_PopIsEverything.png",
                                "gradient_Sex-n-roll.png",
                                "gradientBlue1.png",
                                "gradientHue240-480.png"
                             };
color[] gradient;

ArrayList<Circle> circles = new ArrayList<Circle>();

/*
String paletteFileName = "selected2";
ArrayList<Palette> palettes;
Palette currentPalette;
boolean paletteLock = false;
*/

float scale;

void setup()
{
  //size(768, 768);
  fullScreen();
  
  scale = (width+height)/(768.0*2);
  
  blendMode(ADD);
  
  gradient = loadGradient(gradientFilename);
  
  reset(true);
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

void keyPressed()
{
  switch (key)
  {
    case ' ':
      save("058_" + System.currentTimeMillis() + ".png");
      break;
  }
}

void draw()
{
}

void reset(boolean newColors)
{
  if (newColors)
  {
    int index = (int)random(0, gradientFilenames.length);
    gradient = loadGradient(gradientFilenames[index]);
  }
  
  background(0);
  
  circles.clear();

  stroke(255);
  strokeWeight(1);
  strokeJoin(ROUND);
  noFill();
  
  float minDistance = random(2, 3) * scale;
  int circleCount = 300;
  float multiplier = 1;
  for (int i = 0; i < circleCount; i++)
  {
    float radius = scale * random(50, 200) * multiplier;
    PVector position = new PVector();
    do
    {
      position.x = random(radius, width - radius);
      position.y = random(radius, height - radius);
      radius--;
    } while((radius > 0) && circleOverlap(position, radius, minDistance));
    
    if (radius == 0)
      continue;

    circles.add(new Circle(position, radius));
    //ellipse(position.x, position.y, radius * 2, radius * 2);
    
    //multiplier *= random(0.5, 1);
  }
  
  float outDistance = width+height;
  float castDistance = outDistance * 2;
  
  int lineCount = (int)(400 * scale);
  float offsetDistance = 240.0 / lineCount;
  float startAngle = random(0, TWO_PI);
  PVector startDirection = directionFromAngle(startAngle, 1f);
  PVector offsetDelta = directionFromAngle(startAngle + HALF_PI, offsetDistance);
  PVector startPosition = new PVector(width/2, height/2);
  startPosition.add(directionFromAngle(startAngle + PI, outDistance));
  startPosition.add(PVector.mult(offsetDelta, -lineCount/2));
 
  ArrayList<PVector> previousPositions = new ArrayList<PVector>();
  
  for (int i = 0; i < lineCount; i++)
  {
    previousPositions.clear();
    
    strokeWeight(1);
    stroke(getColor(i/(float)(lineCount-1)), 30);
    //fill(getColor(i/(float)(lineCount-1)), 5);
    
    PVector position = new PVector(startPosition.x, startPosition.y);
    PVector direction = new PVector(startDirection.x, startDirection.y);
    
    int reflectionCounter = 3000;
    boolean hit;
    boolean firstHit = false;
    /*
    if (firstHit)
    {
      beginShape();
      //ellipse(position.x, position.y, 5, 5);
      vertex(startPosition.x, startPosition.y);
    }
    */
    
    //PVector prevFrom = null;
    do
    {
      //if (abs(direction.y) < 0.05) break;
      
      PVector from = new PVector(position.x, position.y);
    
      hit = reflect(position, direction, castDistance);
      if (!firstHit)
      {
        if (hit)
        {
          firstHit = true; 
          beginShape();
          //ellipse(position.x, position.y, 5, 5);
          vertex(startPosition.x, startPosition.y);
        }
        else
        {
          break;
        }
      }
      //ellipse(position.x, position.y, 5, 5);
      //vertex(position.x, position.y);
      
      boolean done = false;
      for (int j = max(0, previousPositions.size() - 10); j < previousPositions.size() - 1; j++)
      {
        float dist = PVector.dist(position, previousPositions.get(j));
        if (dist <= 1.5)
        {
          done = true;
          break;
        }
      }
      
      if (done)
        break;
      
      line(from.x, from.y, position.x, position.y);
      
      previousPositions.add(new PVector(position.x, position.y));
      
      /*
      if (prevFrom != null)
      {
        beginShape();
        vertex(position.x, position.y);
        vertex(from.x, from.y);
        vertex(prevFrom.x, prevFrom.y);
        endShape(CLOSE);
      }
      */
      
      //prevFrom = from;
      
      reflectionCounter--;
    } while ((reflectionCounter > 0) && hit);
    
    //if (reflectionCounter == 0) ellipse(position.x, position.y, 10, 10);
    
    if (firstHit)
    {
      //vertex(position.x + direction.x * castDistance, position.y + direction.y * castDistance);
      endShape();
    }
    
    startPosition.x += offsetDelta.x;
    startPosition.y += offsetDelta.y;
  }
}

boolean reflect(PVector position, PVector direction, float distance)
{
  ArrayList<PVector> results = new ArrayList<PVector>();
  PVector to = PVector.add(position, PVector.mult(direction, distance));
  
  PVector closestHit = to;
  float closestHitDistance = distance;
  float closestHitAngle = 0;
  for (Circle circle : circles)
  {
    int hits = circle.getLineIntersections(position, to, results);
    if (hits > 0)
    {
      for (PVector hit : results)
      {
        float hitDistance = PVector.dist(position, hit);
        if (hitDistance < 0.1)
          continue;
          
        if (hitDistance < closestHitDistance)
        {
          PVector delta = PVector.sub(hit, circle.center);
          closestHit = hit;
          closestHitDistance = hitDistance;
          closestHitAngle = atan2(delta.y, delta.x);
        }
      }
    }
  }
  
  position.x = closestHit.x;
  position.y = closestHit.y;
  
  if (closestHitDistance < distance)
  {
    PVector dir1 = new PVector(cos(closestHitAngle - HALF_PI), sin(closestHitAngle - HALF_PI));
    PVector dir2 = new PVector(cos(closestHitAngle + HALF_PI), sin(closestHitAngle + HALF_PI));
    float dot1 = dir1.dot(direction);
    float dot2 = dir2.dot(direction);
    
    if (dot1 > dot2)
    {
      direction.x = dir1.x;
      direction.y = dir1.y;
    }
    else
    {
      direction.x = dir2.x;
      direction.y = dir2.y;
    }
    
    return true;
  }
  
  return false;
}

color getColor(float percent)
{
  return getColor(gradient, percent);
}

PVector directionFromAngle(float angle, float distance)
{
  return new PVector(cos(angle) * distance, sin(angle) * distance);
}

boolean circleOverlap(PVector center, float radius, float minDistance)
{
  for (Circle circle : circles)
  {
    float distance = PVector.dist(center, circle.center);
    if (distance <= (radius + circle.radius + minDistance))
      return true;
  }
  
  return false;
}

class Circle
{
  PVector center;
  float radius;
  
  public Circle(PVector center, float radius)
  {
    this.center = center;
    this.radius = radius;
  }
  
  public int getLineIntersections(PVector pointA, PVector pointB, ArrayList<PVector> results)
  {
    results.clear();
    
    float baX = pointB.x - pointA.x;
    float baY = pointB.y - pointA.y;
    float caX = center.x - pointA.x;
    float caY = center.y - pointA.y;
    
    float a = baX * baX + baY * baY;
    float bBy2 = baX * caX + baY * caY;
    float c = caX * caX + caY * caY - radius * radius;
    
    float pBy2 = bBy2 / a;
    float q = c / a;
    
    float disc = pBy2 * pBy2 - q;
    
    if (disc < 0)
        return 0;

    // if disc == 0 ... dealt with later
    float tmpSqrt = sqrt(disc);
    float abScalingFactor1 = -pBy2 + tmpSqrt;
    float abScalingFactor2 = -pBy2 - tmpSqrt;
    
    results.add(new PVector(pointA.x - baX * abScalingFactor1, pointA.y - baY * abScalingFactor1));
    
    if (disc == 0)
      return 1;
    
    results.add(new PVector(pointA.x - baX * abScalingFactor2, pointA.y - baY * abScalingFactor2));
    return 2;
  }
}