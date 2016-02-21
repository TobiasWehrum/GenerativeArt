/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to pause and take 1000 steps.
- Right-click to pause/unpause.
- 1/2/3 switches between velocity/mixed/position modes.
*/

ArrayList<SandGrain> sandGrains = new ArrayList<SandGrain>();
ArrayList<Attractor> attractors = new ArrayList<Attractor>();
boolean pause;
int mode;

void setup()
{
  size(768, 768, P3D);
  //colorMode(ADD);
  //noSmooth();
  stroke(255, 255, 255, 100);
  reset();
  mode = 1;
}

void keyPressed()
{
  if (key == '1')
  {
    mode = 1;
    println("Velocity mode");
  }
  else if (key == '2')
  {
    mode = 2;
    println("Mixed mode");
  }
  else if (key == '3')
  {
    mode = 3;
    println("Position mode");
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset();
  }
  else if (mouseButton == CENTER)
  {
    pause = false;
    for (int i = 0; i < 1000; i++)
    {
      draw();
    }
    pause = true;
  }
  else if (mouseButton == RIGHT)
  {
    pause = !pause;
  }
}

void reset()
{
  background(0);
  sandGrains.clear();
  attractors.clear();
  
  int attractorCount = (int) random(2, 5);
  for (int i = 0; i < attractorCount; i++)
  {
    //attractors.add(random(0, 1) > 0.5 ? new AttractorLine() : new AttractorCircle());
    attractors.add(new AttractorCircle());
  }
  
  pause = false;
}

void draw()
{
  if (pause)
    return;

  sandGrains.add(new SandGrain());
  
  for (SandGrain sandGrain : sandGrains)
  {
    for (Attractor attractor : attractors)
    {
      sandGrain.velocity.add(attractor.attract(sandGrain.position));
    }
    sandGrain.draw();
  }
}

class SandGrain
{
  PVector position;
  PVector previousPosition;
  PVector acceleration;
  PVector velocity;
  float decay;
  
  SandGrain()
  {
    position = new PVector(random(0, width), random(0, height));
    previousPosition = new PVector(position.x, position.y);
    acceleration = new PVector();
    velocity = new PVector();
    decay = 1 - pow(random(0, 1), 5);
  }
  
  void draw()
  {
    //velocity.add(acceleration);
    position.add(velocity);
    
    if (mode == 2)
    {
      velocity.mult(decay);
    }
    else if (mode == 3)
    {
      velocity.x = 0;
      velocity.y = 0;
    }
    
    point(position.x, position.y);
    //line(position.x, position.y, previousPosition.x, previousPosition.y);
    previousPosition.x = position.x;
    previousPosition.y = position.y;
  }
}

interface Attractor
{
  abstract PVector attract(PVector element);
}

class AttractorLine implements Attractor
{
  PVector positionA;
  PVector positionB;
  float attractionRadius;
  float attractionRadiusSq;
  float attraction;
  float index;
  boolean inverted;
  
  AttractorLine()
  {
    positionA = new PVector(random(0, width), random(0, height));
    do
    {
      positionB = new PVector(random(0, width), random(0, height));
    } while ((positionA.x == positionB.x) && (positionA.y == positionB.y));
    
    attraction = random(0, 10);
    attractionRadius = random(1, 500);
    attractionRadiusSq = attractionRadius * attractionRadius;

    index = random(0, 100000);
    
    inverted = random(0, 1) > 0.9;
  }
  
  PVector attract(PVector element)
  {
    PVector closestPointOnLine = closestPointOnLine(positionA, positionB, element);
    PVector delta = PVector.sub(closestPointOnLine, element);
    
    float distanceSq = delta.magSq();
    if (distanceSq >= attractionRadiusSq)
      return new PVector();
      
    float distance = sqrt(distanceSq);
    float strength = attraction * pow(map(distance, 0, attractionRadius, 0, 1), 2);
    
    strength *= noise(index + frameCount * 0.01);
    
    if (inverted)
      strength *= -1;
    
    delta.normalize();
    delta.mult(strength);
    return delta;
  }
  
  PVector closestPointOnLine(PVector vA, PVector vB, PVector vPoint)
  {
    PVector vVector1 = PVector.sub(vPoint, vA);
    PVector vVector2 = PVector.sub(vB, vA).normalize();
     
    float d = PVector.dist(vA, vB);
    float t = PVector.dot(vVector2, vVector1);
     
    if (t <= 0)
      return vA;
     
    if (t >= d)
      return vB;
     
    PVector vVector3 = PVector.mult(vVector2, t);
     
    PVector vClosestPoint = PVector.add(vA, vVector3);
    
    return vClosestPoint;
  }
}

class AttractorCircle implements Attractor
{
  PVector position;
  float radiusTarget;
  float innerAttraction;
  float innerAttractionRadius;
  float innerAttractionRadiusSq;
  float outerAttraction;
  float outerAttractionRadius;
  float outerAttractionRadiusSq;
  float index;
  boolean inverted;
  
  AttractorCircle()
  {
    position = new PVector(random(0, width), random(0, height));
    radiusTarget = random(0, 500);
    innerAttraction = random(0, 10);
    innerAttractionRadius = radiusTarget * random(0, 1);
    outerAttraction = random(0, 10);
    outerAttractionRadius = radiusTarget + random(0, 500);
    
    innerAttractionRadiusSq = innerAttractionRadius * innerAttractionRadius;
    outerAttractionRadiusSq = outerAttractionRadius * outerAttractionRadius;
    
    index = random(0, 100000);
    
    //inverted = random(0, 1) > 0.9;
  }
  
  PVector attract(PVector element)
  {
    PVector delta = PVector.sub(position, element);
    float distanceSq = delta.magSq();
    if (distanceSq >= outerAttractionRadiusSq)
      return new PVector();
      
    if (distanceSq <= innerAttractionRadiusSq)
      return new PVector();
      
    float distance = sqrt(distanceSq);
    float strength;
    if (distance < radiusTarget)
    {
      delta.mult(-1);
      strength = innerAttraction * pow(map(distance, innerAttractionRadius, radiusTarget, 1, 0), 2);
    }
    else
    {
      strength = outerAttraction * pow(map(distance, radiusTarget, outerAttractionRadius, 0, 1), 2);
    }

    strength *= noise(index + frameCount * 0.01);
    
    if (inverted)
      strength *= -1;
    
    delta.normalize();
    delta.mult(strength);
    return delta;
  }
}