ArrayList<Boid> boids = new ArrayList<Boid>();
boolean pause;

void setup()
{
  size(768, 768, P3D);
  blendMode(ADD);
  colorMode(HSB, 360, 100, 100, 255);
  reset();
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
  boids.clear();
  for (int i = 0; i < 100; i++)
  {
    boids.add(new Boid(new PVector(random(0, width), random(0, height))));
  }

  background(0);
  //stroke(140, 1);
  stroke(0, 0, 100, 255);
  //stroke(255);
  noFill();
  
  pause = false;
}

void draw()
{
  if (pause)
    return;
  
  strokeWeight(2);
  //stroke(255, min((frameCount / 15), 20));
  background(0);
  for (Boid boid : boids)
  {
    boid.update();
    boid.draw();
  }
}

class Boid
{
  PVector velocity;
  PVector position;
  PVector previousPosition;
  float maxSpeed = 2;
  float maxForce = 0.2;
  float angle;
  float index;
  
  Boid(PVector position)
  {
    this.position = position;
    
    angle = random(0, PI*2);
    this.velocity = new PVector(cos(angle) * maxSpeed, sin(angle) * maxSpeed);
    
    PVector delta = new PVector(width / 2 - position.x, height / 2 - position.y);
    delta.normalize();
    if ((delta.x == 0) && (delta.y == 0))
    {
      delta.x = 1;
    }
    
    previousPosition = new PVector(position.x, position.y);
    
    index = random(0, 1000000);
  }
  
  void update()
  {
    PVector sep = separate();
    PVector ali = align();
    PVector coh = cohesion();
    PVector wan = wander();
    
    sep.mult(1.5);
    ali.mult(1);
    coh.mult(1);
    wan.mult(1.5);
    
    velocity.add(sep);
    velocity.add(ali);
    velocity.add(coh);
    velocity.add(wan);
    
    velocity.limit(maxSpeed);
    
    position.add(PVector.mult(velocity, 0.3));

    if (position.x < 0)
    {
      position.x += width;
      previousPosition.x += width;
    }
    else if (position.x >= width)
    {
      position.x -= width;
      previousPosition.x -= width;
    }
      
    if (position.y < 0)
    {
      position.y += height;
      previousPosition.y += height;
    }
    else if (position.y >= height)
    {
      position.y -= height;
      previousPosition.y -= height;
    }
  }
  
  void draw()
  {
    stroke(0, 0, 100, 10);
    
    float neighborDistance = 50;
    int count = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;
      
      PVector delta = getWrappedDelta(position, boid.position);
      float distance = delta.mag();
      if (distance > neighborDistance)
        continue;
      
      if (PVector.dist(position, boid.position) <= neighborDistance)
      {
        line(position.x, position.y, boid.position.x, boid.position.y);
      }
      
      count++;
    }
    
    stroke(0, 0, 100, 255);
    
    line(previousPosition.x, previousPosition.y, position.x, position.y);
    ellipse(position.x, position.y, count, count);
    previousPosition.x = position.x;
    previousPosition.y = position.y;
  }
  
  PVector wander()
  {
    angle += lerp(-1, 1, noise(index + frameCount * 0.001)) * 0.1;

    PVector dir = new PVector(cos(angle) * maxSpeed, sin(angle) * maxSpeed);
    
    PVector steer = PVector.sub(dir, velocity);
    steer.limit(maxForce);
    return steer;
  }

  PVector separate()
  {
    float neighborDistance = 50;
    PVector sum = new PVector();
    int count = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;
      
      PVector delta = getWrappedDelta(position, boid.position);
      float distance = delta.mag();
      if (distance > neighborDistance)
        continue;
      
      delta.mult(-1);
      
      //PVector delta = PVector.sub(position, boid.position);
      
      delta.normalize();
      //delta.div(distance);
      sum.add(delta);
      count++;
    }
    
    if (count == 0)
      return new PVector();
    
    sum.div(count);
    
    PVector steer = PVector.sub(sum, velocity);
    steer.limit(maxForce);
    return steer;
  }

  PVector align()
  {
    float neighborDistance = 150;
    PVector sum = new PVector();
    int count = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;
      
      PVector delta = getWrappedDelta(position, boid.position);
      if (delta.mag() > neighborDistance)
        continue;
        
      sum.add(boid.velocity);
      count++;
    }
    
    if (count == 0)
      return new PVector();
    
    sum.setMag(maxSpeed);
    
    PVector steer = PVector.sub(sum, velocity);
    steer.limit(maxForce);
    return steer;
  }

  PVector cohesion()
  {
    float neighborDistance = 150;
    PVector sum = new PVector();
    int count = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;

      PVector delta = getWrappedDelta(position, boid.position);
      if (delta.mag() > neighborDistance)
        continue;

      sum.add(PVector.add(position, delta));
      count++;
    }
    
    if (count == 0)
      return new PVector();
      
    sum.div(count);

    PVector dir = PVector.sub(sum, position);
    
    PVector steer = PVector.sub(dir, velocity);
    steer.limit(maxForce);
    return steer;
  }
}

PVector getWrappedDelta(PVector from, PVector to)
{
  float dx = to.x - from.x;
  float dy = to.y - from.y;
  if (dx > width / 2)
  {
    dx = width - dx;
  }
  if (dy > height / 2)
  {
    dy = height - dy;
  }
  return new PVector(dx, dy);
}

PVector getWrappedPosition(PVector point, PVector reference)
{
  return PVector.add(reference, getWrappedDelta(reference, point));
}