/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to take 1000 steps and pause.
- Right-click to pause/unpause.
*/

ArrayList<Boid> boids = new ArrayList<Boid>();
boolean pause;
float hue = 0;
float saturation = 0;
float alpha = 1;

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
  for (int i = 0; i < 50; i++)
  {
    boids.add(new Boid(new PVector(random(0, width), random(0, height))));
  }

  background(0);
  //stroke(140, 1);
  stroke(0, 0, 100, 255);
  fill(0, 0, 50, 255);
  //stroke(255);
  //noFill();
  
  pause = false;
}

void draw()
{
  if (pause)
    return;
  
  strokeWeight(1);
  //stroke(255, min((frameCount / 15), 20));
  //background(0);
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
  float maxForce = 0.5;
  float angle;
  float index;
  PVector acc;
  
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
    
    acc = new PVector();
  }
  
  void update()
  {
    PVector sep = separate();
    PVector ali = align();
    PVector coh = cohesion();
    PVector wan = wander();
    
    sep.mult(0.01);
    ali.mult(-0.25);
    coh.mult(0.05);
    wan.mult(1.5);
    
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
    //velocity.add(wan);
    
    acc.limit(maxForce);
    
    velocity.add(acc);
    
    velocity.limit(maxSpeed);
    
    position.add(PVector.mult(velocity, 0.5));

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
    stroke(hue, saturation, 100, alpha);
    
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
    
    //line(previousPosition.x, previousPosition.y, position.x, position.y);
    //ellipse(position.x, position.y, 3, 3);
    //previousPosition.x = position.x;
    //previousPosition.y = position.y;
    
    PVector direction = new PVector(velocity.x, velocity.y);
    direction.normalize();
    
    float a = 10f;
    float b = 4f;
    float c = 5f;
    
    float ax = position.x + direction.x * a;
    float ay = position.y + direction.y * a;
    float bx = position.x - direction.x * b + direction.y * c;
    float by = position.y - direction.y * b - direction.x * c;
    float cx = position.x - direction.x * b - direction.y * c;
    float cy = position.y - direction.y * b + direction.x * c;
    
    //triangle(ax, ay, bx, by, cx, cy);
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
    float neighborDistance = 40;
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
      delta.div(1 - (distance / neighborDistance));
      sum.add(delta);
      count++;
    }
    
    if (count == 0)
      return new PVector();
    
    sum.div(count);
    
    sum.normalize();
    if (true) return sum;
    
    PVector steer = PVector.sub(sum, velocity);
    steer.limit(maxForce);
    return steer;
  }

  PVector align()
  {
    float neighborDistance = 140;
    PVector sum = new PVector();
    int count = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;
      
      PVector delta = getWrappedDelta(position, boid.position);
      if (delta.mag() > neighborDistance)
        continue;
        
      if (delta.mag() <= 40)
        continue;
        
      sum.add(boid.velocity);
      count++;
    }
    
    if (count == 0)
      return new PVector();
    
    sum.setMag(maxSpeed);
    sum.normalize();
    if (true) return sum;
    PVector steer = PVector.sub(sum, velocity);
    steer.limit(maxForce);
    return steer;
  }

  PVector cohesion()
  {
    float neighborDistance = 180;
    PVector sum = new PVector();
    int count = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;

      PVector delta = getWrappedDelta(position, boid.position);
      if (delta.mag() > neighborDistance)
        continue;

      if (delta.mag() <= 40)
        continue;
        
      sum.add(PVector.add(position, delta));
      count++;
    }
    
    if (count == 0)
      return new PVector();
      
    sum.div(count);

    PVector dir = PVector.sub(sum, position);
    dir.normalize();
    if (true) return dir;
    PVector steer = PVector.sub(dir, velocity);
    steer.limit(maxForce);
    return steer;
  }
}

PVector getWrappedDelta(PVector from, PVector to)
{
  float dx = to.x - from.x;
  float dy = to.y - from.y;
  /*
  if (dx > width / 2)
  {
    dx = width - dx;
  }
  if (dy > height / 2)
  {
    dy = height - dy;
  }
  */
  return new PVector(dx, dy);
}

PVector getWrappedPosition(PVector point, PVector reference)
{
  return PVector.add(reference, getWrappedDelta(reference, point));
}