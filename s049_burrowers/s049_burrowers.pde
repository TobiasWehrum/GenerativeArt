/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to pause/resume.
*/

boolean paused;
float time;
ArrayList<Creature> creatures = new ArrayList<Creature>();

void setup()
{
  size(768, 768);
  //blendMode(ADD);
  
  frameRate(130);
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
    paused = !paused;
  }
}

void keyPressed()
{
  switch (key)
  {
    case ' ':
      save("049_burrowers_" + frameCount + ".png");
      break;
  }
}

void reset()
{
  noiseSeed(floor(random(0, 10000000)));
  
  time = 0;
  creatures.clear();
  for (int i = 0; i < 10; i++)
    creatures.add(new Creature(new PVector(random(0, width), random(0, height)), width/10));
  
  paused = false;
  
  background(0);
}

void draw()
{
  
  if (paused)
    return;
  
  for (int i = 0; i < 1; i++)
    step();
}

void step()
{
  time++;
  for (Creature creature : creatures)
  {
    creature.draw();
  }
}

class Creature
{
  float noiseIndex;
  PVector center;
  float radius;
  float angle;
  float speed;
  ArrayList<Tentacle> tentacles = new ArrayList<Tentacle>();
  
  Creature(PVector center, float radius)
  {
    this.center = center;
    this.radius = radius;
    noiseIndex = random(0, 10000);
    
    int count = floor(random(5, 8));
    float angleStart = random(0, PI*2);
    float angleDelta = (PI*2)/count;
    for (int i = 0; i < count; i++)
      tentacles.add(new Tentacle(this, angleStart + angleDelta * i));
      
    angle = random(0, PI*2);
    speed = random(0.3, 0.6);
  }
  
  void draw()
  {
    angle += (noise(noiseIndex, 0, time * 0.01) * 2 - 1) * (PI/300);
    
    center.x += cos(angle) * speed;
    center.y += sin(angle) * speed;
    
    center.x = (center.x + width) % width;
    center.y = (center.y + height) % height;
    
    noFill();
    
    //blendMode(ADD);
    for (Tentacle tentacle : tentacles)
    {
      stroke(255, 10);
      tentacle.draw();
    }
    
    //blendMode(NORMAL);
    for (int i = 0; i < tentacles.size() - 1; i++)
    {
      for (int j = i + 1; j < tentacles.size(); j++)
      {
        stroke(0, 20);
        PVector from = tentacles.get(i).from;
        PVector to = tentacles.get(j).from;
        line(from.x, from.y, to.x, to.y);
      }
    }
  }
}

class Tentacle
{
  Creature creature;
  float noiseIndex;
  float angle;
  float angleSpeed;
  float radius;
  float radiusSpeed;
  PVector from = new PVector();
  
  Tentacle(Creature creature, float angle)
  {
    this.creature = creature;
    noiseIndex = random(0, 10000);
    
    this.angle = angle;
    this.radius = creature.radius;
    
    angleSpeed = random(-1, 1) * 0.1; // 0.05;
    radiusSpeed = random(0.3, 1) * 0.2; // 0.2
  }
  
  void draw()
  {
    float timeOffsetInner = time * 0.1;
    float timeOffsetAngle = time * 0.1;
    float timeOffsetAngle2 = time * 0.1;
    
    PVector offset = new PVector(noise(noiseIndex, 0, timeOffsetInner) * 2 - 1,
                                 noise(noiseIndex, 1, timeOffsetInner) * 2 - 1);
    if (offset.magSq() > 1)
      offset.normalize();
    
    from.x = creature.center.x + offset.x * creature.radius;
    from.y = creature.center.y + offset.y * creature.radius;
    
    float currentAngle = angle + (noise(noiseIndex, 2, timeOffsetAngle) * 2 - 1) * PI;
    float currentRadius = radius * noise(creature.noiseIndex, currentAngle);
    float toX = creature.center.x + cos(currentAngle) * currentRadius;
    float toY = creature.center.y + sin(currentAngle) * currentRadius;
    
    line(from.x, from.y, toX, toY);
    
    radius += radiusSpeed;
    angle += angleSpeed;
  }
}