/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to pause/resume.
*/

import java.util.Collections;

boolean paused;
float time;
float baseScale = 1;
float scale;
PGraphics pSave;
PGraphics newLayer;
PGraphics previousPicture;
ArrayList<Attractor> attractors = new ArrayList<Attractor>();
int screenshotSeriesUID;
int screenshotNumber;

void setup()
{
  size(768, 768);
  //fullScreen();
  
  baseScale = (width+height)/(768.0*2);
  
  blendMode(ADD);
  
  pSave = createGraphics(width, height);
  newLayer = createGraphics(width, height);
  previousPicture = createGraphics(width, height);
  
  frameRate(30);
  reset();
}

void mouseClicked()
{
  /*
  if (mouseButton == LEFT)
  {
    commit();
    renderLayer();
  }
  else if (mouseButton == CENTER)
  {
    renderLayer();
  }
  else if (mouseButton == RIGHT)
  {
    reset();
  }
  */
}

void keyPressed()
{
  switch (key)
  {
    case 'q':
      savePreviousPicture();
      commit();
      renderLayer();
      break;
      
    case 'w':
      savePreviousPicture();
      renderLayer();
      break;
      
    case 'e':
      savePreviousPicture();
      remove();
      refresh();
      break;
      
    case 'r':
      savePreviousPicture();
      reset();
      break;
    
    case '\t':
      background(0);
      image(previousPicture, 0, 0);
      break;
   
    case 'a':
      commitPreviousPicture();
      refresh();
      break;
    
    case ' ':
      save("058_" + screenshotSeriesUID + "_" + screenshotNumber + ".png");
      screenshotNumber++;
      break;
  }
}

void draw()
{
}

void reset()
{
  screenshotSeriesUID = floor(random(0, 10000000));
  screenshotNumber = 1;
  
  noiseSeed(floor(random(0, 10000000)));

  time = 0;
  
  paused = false;
  
  pSave.beginDraw();
  pSave.background(0);
  pSave.endDraw();
  
  background(0);
  
  scale = baseScale * random(0.5, 2);
  
  createAttractors();
  
  int layerCount = (int)random(3, 6);
  layerCount = 1;
  for (int i = 0; i < layerCount; i++)
  {
    renderLayer();
    //println(((float)(i+1)/layerCount) * 100 + "%");
  }
}

void createAttractors()
{
  int maxPosAttractorCount = 10;
  float maxPosAttractorForce = 100;
  int maxNegAttractorCount = 3;
  float maxNegAttractorForce = 50;
  
  attractors.clear();
  for (int i = 0; i < maxPosAttractorCount; i++)
    attractors.add(new Attractor(randomPosition(), scaledRandom(maxPosAttractorForce)));
    
  for (int i = 0; i < maxNegAttractorCount; i++)
    attractors.add(new Attractor(randomPosition(), scaledRandom(maxNegAttractorForce) * -1));
  
  Collections.shuffle(attractors);
}

void renderLayer()
{
  stroke(255);
  noFill();
  
  //for (Attractor a : attractors) ellipse(a.pos.x, a.pos.y, 100, 100);

  newLayer.beginDraw();
  newLayer.background(0);
  newLayer.blendMode(ADD);
  newLayer.noFill();

  int spotCount = (int)random(1, 4);
  spotCount = 1;
  for (int i = 0; i < spotCount; i++)
    renderIntoLayer(attractors);
    
  newLayer.endDraw();
  
  refresh();
}

void savePreviousPicture()
{
  pSave.beginDraw();
  pSave.endDraw();
  
  newLayer.beginDraw();
  newLayer.endDraw();
  
  previousPicture.beginDraw();
  previousPicture.background(0);
  previousPicture.blendMode(ADD);
  previousPicture.image(pSave, 0, 0);
  previousPicture.image(newLayer, 0, 0);
  previousPicture.endDraw();
}

void refresh()
{
  background(0);
  blendMode(ADD);
  image(pSave, 0, 0);
  image(newLayer, 0, 0);
}

void remove()
{
  newLayer.beginDraw();
  newLayer.background(0);
  newLayer.endDraw();
}

void commit()
{
  newLayer.beginDraw();
  newLayer.endDraw();
  
  pSave.beginDraw();
  pSave.blendMode(ADD);
  pSave.image(newLayer, 0, 0);
  pSave.endDraw();
  
  remove();
}

void commitPreviousPicture()
{
  previousPicture.beginDraw();
  previousPicture.endDraw();
  
  pSave.beginDraw();
  pSave.background(0);
  pSave.image(previousPicture, 0, 0);
  pSave.endDraw();
  
  remove();
}

void renderIntoLayer(ArrayList<Attractor> attractors)
{
  newLayer.stroke(random(0, 255), random(0, 255), random(0, 255), 15);
  PVector center = randomPosition();//new PVector(width / 2, height / 2);
  float rotationSpeed = random(-0.2, 0.2);
  PVector spot = randomPosition();
  float radius = scaledRandom(100, 200);
  int pointCount = (int)scaledRandom(100, 200)*3;
  for (int pi = 0; pi < pointCount; pi++)
  {
    float angle = random(0, PI*2);
    float r = radius * random(0, 1);
    PVector off = new PVector(cos(angle) * r, sin(angle) * r);
    PVector off2 = new PVector(0, 0);
    PVector pos = PVector.add(spot, off);
    
    float prevX = pos.x;
    float prevY = pos.y;
    float speed = random(0.5, 2);
    
    int iterationCount = (int)random(40, 60);
    float var = scaledRandom(0, 2);
    for (int ii = 0; ii < iterationCount; ii++)
    {
      
      for (Attractor a : attractors)
      {
        pos.x += random(-var, var);
        pos.y += random(-var, var);
        pos = a.transform(pos, speed);
      }
      
      pos = rotatePos(pos, rotationSpeed, center);
      
      if (ii > 0)
      {
        newLayer.line(prevX + off2.x, prevY + off2.y, pos.x + off2.x, pos.y + off2.y);
      }
      
      prevX = pos.x;
      prevY = pos.y;
    }
  }
}

PVector rotatePos(PVector pos, float angle, PVector center)
{
  PVector delta = PVector.sub(pos, center);
  float currentAngle = atan2(delta.y, delta.x);
  currentAngle += angle;
  float dist = delta.mag();
  return new PVector(center.x + cos(currentAngle) * dist, center.y + sin(currentAngle) * dist);
}

float scaledRandom()
{
  return scaledRandom(0, 1);
}

float scaledRandom(float value)
{
  return scaledRandom(0, value);
}

float scaledRandom(float from, float to)
{
  return random(from, to) * scale;
}

PVector randomPosition()
{
  return new PVector(random(0, width), random(0, height));
}

class Attractor
{
  PVector pos;
  float force;
  
  Attractor(PVector pos, float force)
  {
    this.pos = pos;
    this.force = force;
  }
  
  PVector transform(PVector in, float speed)
  {
    PVector out = new PVector();
    PVector delta = PVector.sub(pos, in);
    float distance = delta.mag();
    PVector direction = delta.div(distance);
    float currentForce = force / max(sqrt(distance), 1) * speed;
    out.x = in.x + direction.x * currentForce;
    out.y = in.y + direction.y * currentForce;
    return out;
  }
}