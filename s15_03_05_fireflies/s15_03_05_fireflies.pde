/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to spawn a sphere and to deactivate auto-spawn-mode.
- Right-click to refresh (and reactivate auto-spawn-mode).
*/

import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;

ArrayList<Spear> spears = new ArrayList<Spear>();
ArrayList<Target> targets = new ArrayList<Target>();

float alpha = 30;

int spearCountX = 50;
int spearCountY = spearCountX;

float spearLengthBack = 10;
float spearLengthFront = 3;
float spearRotationAcceleration = 0.001;

float glowingTime = 10;
float glowingAlpha = 10;
float glowingRadius = 5;

float pullBackFactor = 0.04;

float targetRadius = 37;
float targetAppearTime = 0.7;
Easing targetAppearEaseAppearance = Ani.EXPO_IN;
float targetAppearTimePower = 0.7;
Easing targetAppearEasePower = Ani.EXPO_IN;

float offsetTimeFactor = 0.01;
float offsetDistance = 10;

float pointStrokeWidth = 1;

float targetSpearPushDistanceFactor = 3;
float targetSpearPushPowerFactor = 0.5;
float targetSpearPushPowerMin = 1;
  
float delayBetweenTargets = 2;
float firstTargetDelay = 1;
float nextTargetCountdown;

float spearExplosionSpeed = 10;
float spearDeaccelerationFactor = 0.93;

float timeUntilFirstPierceRequest = 1;
float delayBetweenPierceRequests = 0.03;
//int pierceRequestCount = 10;
float reducedRadiusPerHit = 0.4;

boolean closest = true;

class Spear
{
  float offsetBaseIndex;
  
  PVector startPosition;
  PVector position;
  PVector direction;
  PVector velocity;
  
  float currentAngle;
  //float targetAngle;
  float currentRotationSpeed;
  
  PVector previousPosition;
  
  Target currentTarget;
  
  int piercing;
  
  float delay = 0;
  
  float c;
  
  float glowingTimeLeft;
  
  Spear(PVector position, PVector direction)
  {
    offsetBaseIndex = random(1000);
    
    startPosition = new PVector(position.x, position.y);
    this.position = position;
    previousPosition = new PVector(position.x, position.y);
    this.direction = direction;
    this.direction.normalize();
    
    velocity = new PVector();
    
    currentAngle = atan2(direction.y, direction.x);
    //targetAngle = currentAngle;
    
    c = random(255);
  }
  
  boolean isGlowing()
  {
    return glowingTimeLeft > 0;
  }
  
  boolean readyToPierce(Target target)
  {
    return ((currentTarget == target) && (piercing == 0)); //  && (currentAngle == targetAngle)
  }
  
  void pierce()
  {
    /*
    currentAngle = targetAngle;
    direction.x = cos(currentAngle);
    direction.y = sin(currentAngle);
    */
    
    piercing = 1;
    
    float targetX = currentTarget.position.x - direction.x * currentTarget.currentRadius;
    float targetY = currentTarget.position.y - direction.y * currentTarget.currentRadius;
    
    float duration = 0.5;
    Easing ease = Ani.QUINT_IN; 
    
    Ani.to(position, duration, "x", targetX, ease);
    Ani.to(position, duration, "y", targetY, ease); 
    
    delay = duration;
  }
  
  void targetExploded()
  {
    piercing = 0;
    
    float angle = random(PI * 2);
    //float angle = targetAngle + PI + 0.8;
    float x = cos(angle);
    float y = sin(angle);
    
    velocity.x = x * spearExplosionSpeed;
    velocity.y = y * spearExplosionSpeed;
  }
  
  void setTarget(Target target)
  {
    if (target == currentTarget)
      return;
    
    currentTarget = target;
    if (target != null)
    {
      currentAngle = atan2(target.position.y - position.y, target.position.x - position.x);
      direction.x = target.position.x - position.x;
      direction.y = target.position.y - position.y;
      direction.normalize();
    }
  }
  
  Target findClosestTarget()
  {
    Target closestTarget = null;
    float closestTargetDistance = 0;
    
    for (Target target : targets)
    {
      if (target.currentRadius <= 1)
        continue;
      
      float distance = PVector.dist(position, target.position);
      if ((closestTarget == null) || (distance < closestTargetDistance))
      {
        closestTarget = target;
        closestTargetDistance = distance;
      }
    }
    
    return closestTarget;
  }
  
  PVector getPushFromTarget(Target target)
  {
    PVector delta = new PVector(position.x - target.position.x, position.y - target.position.y);
    float distance = delta.mag();
    if (distance == 0)
    {
      delta.x = 0.1;
      distance = 0.1;
    }
    float radius = target.currentRadiusPower;
    delta.normalize();
    
    float saveDistance = radius * targetSpearPushDistanceFactor;
    if (distance >= saveDistance)
      return new PVector();
      
    float closenessPercent = 1 - distance / saveDistance;
    float power = max(radius * closenessPercent * targetSpearPushPowerFactor,
                      targetSpearPushPowerMin);
    
    delta.setMag(power);
    return delta;
  }
  
  void update()
  {
    if (glowingTimeLeft > 0)
    {
      glowingTimeLeft -= 1.0 / frameRate;
    }
    
    if (piercing > 0)
    {
      if (delay > 0)
      {
        delay -= 1.0 / frameRate;
        if (delay <= 0)
        {
          piercing++;
          currentTarget.hit();
          glowingTimeLeft = glowingTime;
        }
      }
      
      if (piercing == 2)
      {
        position.x = currentTarget.position.x - direction.x * currentTarget.currentRadius;
        position.y = currentTarget.position.y - direction.y * currentTarget.currentRadius;
      }
      
      return;
    }
    
    PVector push = new PVector();
    for (Target target : targets)
    {
      push.add(getPushFromTarget(target));
    }
    
    velocity.setMag(velocity.mag() * spearDeaccelerationFactor);
    
    push.add(velocity);

    PVector deltaTowardsStart = new PVector(startPosition.x - position.x,
                                            startPosition.y - position.y);
    float distanceToStart = deltaTowardsStart.mag();
    deltaTowardsStart.setMag(max(distanceToStart * pullBackFactor, 0));
    
    push.add(deltaTowardsStart);
    
    position.x += push.x;
    position.y += push.y;
    
    if (position.x < 0)
      position.x = 0;
    
    if (position.y < 0)
      position.y = 0;
    
    if (position.x > width)
      position.x = width;
    
    if (position.y > height)
      position.y = height;
    
    if (velocity.mag() > 0.5)
      return;
    
    setTarget(findClosestTarget());
    
    //targetAngle = atan2(mouseY - position.y, mouseX - position.x); 
    /*
    if (currentAngle == targetAngle)
    {
      currentRotationSpeed = 0;
      return;
    } 
    
    float rotationDelta = targetAngle - currentAngle;
    while (rotationDelta < 0)
    {
      rotationDelta += PI * 2;
    }
    rotationDelta %= PI * 2;
    
    if (rotationDelta > PI)
    {
      rotationDelta = PI - rotationDelta;
    }
    
    float rotationDirection = (rotationDelta > 0) ? 1 : -1;
    
    rotationDelta = abs(rotationDelta);
    
    currentRotationSpeed += spearRotationAcceleration;
    currentRotationSpeed *= 1.1;
    
    float rotationDistance = currentRotationSpeed;
    
    if (rotationDistance >= rotationDelta)
    {
      currentRotationSpeed = 0;
      currentAngle = targetAngle;
    }
    else
    {
      currentAngle += rotationDistance * rotationDirection;
    }
    
    
    direction.x = cos(currentAngle);
    direction.y = sin(currentAngle);
    */
  }
  
  void draw()
  {
    PVector positionWithOffset = new PVector(position.x, position.y);
    if ((piercing == 0) || (piercing >= 2))
    {
      float index = offsetTimeFactor * frameCount;
      positionWithOffset.x += lerp(-offsetDistance, offsetDistance, noise(offsetBaseIndex + index, 0)) * (piercing + 1);
      positionWithOffset.y += lerp(-offsetDistance, offsetDistance, noise(offsetBaseIndex + index, 10)) * (piercing + 1);
    }
    
    /*
    line(position.x - direction.x * spearLengthBack, position.y - direction.y * spearLengthBack,
         position.x + direction.x * spearLengthFront, position.y + direction.y * spearLengthFront);
    */
    
    //fill(c, 255, 255, 255);
    stroke(c, 255, 255, 255);
    strokeWeight(pointStrokeWidth);
    line(previousPosition.x, previousPosition.y, positionWithOffset.x, positionWithOffset.y);
    
    if (isGlowing())
    {
      stroke(c, 255, 255, glowingAlpha);
      strokeWeight(pointStrokeWidth + glowingRadius); //  * (glowingTimeLeft / glowingTime)
      line(previousPosition.x, previousPosition.y, positionWithOffset.x, positionWithOffset.y);
    }
    
    previousPosition.set(positionWithOffset);
    
    //ellipse(position.x, position.y, pointStrokeWidth, pointStrokeWidth);
  }
}

ArrayList<Spear> tempList = new ArrayList<Spear>();

class Target
{
  PVector position;
  float currentRadius;
  float currentRadiusPower;
  float radius;
  boolean shrinking;
  float timeUntilPierceRequest;
  //int count = 0;
  boolean exploded;
  float timeUntilExplosion;
  ArrayList<Spear> hitBy = new ArrayList<Spear>();
  
  Target(PVector position, float radius)
  {
    this.position = position;
    this.radius = radius;
    
    currentRadius = 0;
    Ani.to(this, targetAppearTime, "currentRadius", radius, targetAppearEaseAppearance); 
    Ani.to(this, targetAppearTimePower, "currentRadiusPower", radius, targetAppearEasePower);
    
    timeUntilPierceRequest = timeUntilFirstPierceRequest;
  }
  
  void hit()
  {
    currentRadius -= reducedRadiusPerHit;
    if (currentRadius <= 1)
    {
      currentRadius = 1;
      timeUntilExplosion = 1.5;
    }
  }
  
  void explode()
  {
    for (Spear spear : hitBy)
    {
      spear.targetExploded();
    }
    exploded = true;
  }
  
  void update()
  {
    if (timeUntilExplosion > 0)
    {
      timeUntilExplosion -= 1.0 / frameRate;
      if (timeUntilExplosion <= 0)
      {
        explode();
      }
    }
    
    if (currentRadius <= 1)
      return;
    
    timeUntilPierceRequest -= 1.0 / frameRate;
    if (timeUntilPierceRequest <= 0)
    {
      timeUntilPierceRequest += delayBetweenPierceRequests;

      if (!closest)
      {
        tempList.clear();
        for (Spear spear : spears)
        {
          if (spear.readyToPierce(this))
          {
            tempList.add(spear);
          }
        }
        
        if (tempList.size() > 0)
        {
          int index = (int)random(tempList.size());
          tempList.get(index).pierce();
          hitBy.add(tempList.get(index));
        }
      }
      else
      {
        Spear closestSpear = null;
        float closestSpearDistance = 0;
        
        for (Spear spear : spears)
        {
          if (spear.readyToPierce(this))
          {
            float distance = PVector.dist(position, spear.position);
            if ((closestSpear == null) || (distance < closestSpearDistance))
            {
              closestSpear = spear;
              closestSpearDistance = distance;
            }
          }
        }
        
        if (closestSpear != null)
        {
          closestSpear.pierce();
          hitBy.add(closestSpear);
        }
      }
    }
  }
  
  void draw()
  {
    if (currentRadius <= 1)
      return;
    
    //stroke(0, 0, 255, 255);
    noStroke();
    fill(0, 0, 255, 255);
    ellipse(position.x, position.y, currentRadius * 2, currentRadius * 2);

/*
    int stepCount = 4;
    for (int i = 0; i < 10; i++)
    {
      fill(0, 0, 255, 255 * (0 + ((float) i / stepCount)));
      ellipse(position.x, position.y, currentRadius * 2 + i * 2, currentRadius * 2 + i * 2);
    }
*/ 
  }
}

boolean clickMode = false;  

void setup()
{
  size(500, 500);
  frameRate(30);
  
  Ani.init(this);
  
  float distanceX = (float) width / (spearCountX + 1);
  float distanceY = (float) height / (spearCountY + 1);
  for (int spearX = 0; spearX < spearCountX; spearX++)
  {
    float x = distanceX * (spearX + 1);
    for (int spearY = 0; spearY < spearCountY; spearY++)
    {
      float y = distanceY * (spearY + 1);
      spears.add(new Spear(new PVector(x, y), new PVector(width / 2 - x, height / 2 - y)));
    }
  }
  
  nextTargetCountdown = firstTargetDelay;
  
  colorMode(HSB, 255);
  background(0, 0, 0);
  clickMode = false;
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    targets.add(new Target(new PVector(mouseX, mouseY), targetRadius));
    clickMode = true;
  }
  else if (mouseButton == RIGHT)
  {
    spears.clear();
    targets.clear();
    setup();
  }
}

void draw()
{
  fill(0,alpha);
  noStroke();
  rect(0,0,width,height);
  
  //background(0);
  //stroke(255);
  //strokeWeight(5);
  noFill();

  if (!clickMode)
  {
    nextTargetCountdown -= 1.0 / frameRate;
    if (nextTargetCountdown <= 0)
    {
      nextTargetCountdown += delayBetweenTargets;
      targets.add(new Target(new PVector(random(targetRadius, width - targetRadius),
                                         random(targetRadius, height - targetRadius)),
                             targetRadius));
    }
  }
  
  for (Spear spear : spears)
  {
    spear.update();
    spear.draw();
  }
  
  for (Target target : targets)
  {
    target.update();
    target.draw();
  }
  
  while ((targets.size() > 0) && (targets.get(0).exploded))
  {
    targets.remove(0);
  }
}
