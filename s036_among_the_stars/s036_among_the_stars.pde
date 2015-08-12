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
    attractors.add(new Attractor());
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

class Attractor
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
  
  Attractor()
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
    
    delta.normalize();
    delta.mult(strength);
    return delta;
  }
}
