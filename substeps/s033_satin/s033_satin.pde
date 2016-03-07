ArrayList<Boid> boids = new ArrayList<Boid>();
boolean pause;

void settings()
{
  size(768, 768, P2D);
}

void setup()
{
  blendMode(ADD);
  reset();
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset();
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
  stroke(140, 1);
  
  pause = false;
}

void draw()
{
  if (pause)
    return;
  
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
  
  Boid(PVector position)
  {
    this.position = position;
    previousPosition = new PVector(position.x, position.y);
    
    float angle = random(0, PI*2);
    this.velocity = new PVector(cos(angle) * maxForce, sin(angle) * maxForce);
  }
  
  void update()
  {
    PVector sep = separate();
    PVector ali = align();
    PVector coh = cohesion();
    
    sep.mult(1.5);
    ali.mult(1);
    coh.mult(1);
    
    velocity.add(PVector.add(sep, ali).add(coh));
    velocity.limit(maxSpeed);
    
    position.add(velocity);
  }
  
  void draw()
  {
    //line(previousPosition.x, previousPosition.y, position.x, position.y);
    //previousPosition.x = position.x;
    //previousPosition.y = position.y;

    float neighborDistance = 150;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;
      
      if (PVector.dist(boid.position, position) > neighborDistance)
        continue;
        
      line(position.x, position.y, boid.position.x, boid.position.y);
    }
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
      
      if (PVector.dist(boid.position, position) > neighborDistance)
        continue;
      
      PVector delta = PVector.sub(position, boid.position);
      
      delta.normalize();
      //delta.div(neighborDistance);
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
      
      if (PVector.dist(boid.position, position) > neighborDistance)
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
      
      if (PVector.dist(boid.position, position) > neighborDistance)
        continue;

      sum.add(boid.position);
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