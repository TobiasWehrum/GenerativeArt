/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to pause and take 200 steps.
- Right-click to pause/unpause.
- A to refresh and finish 200 steps with same color scheme.
- S to refresh and finish 200 steps with changed color scheme.

Color schemes:
- "Hymn For My Soul" by faded jeans: http://www.colourlovers.com/palette/81885/Hymn_For_My_Soul
- "Influenza" by Miaka: http://www.colourlovers.com/palette/301154/Influenza
- "s e x ' n . r o l l " by tvr: http://www.colourlovers.com/palette/401946/s_e_x_n_._r_o_l_l
- "A Dream in Color" by madmod001: http://www.colourlovers.com/palette/871636/A_Dream_in_Color
- "fresh cut day" by electrikmonk: http://www.colourlovers.com/palette/46688/fresh_cut_day
- "Ocean Five" by DESIGNJUNKEE: http://www.colourlovers.com/palette/1473/Ocean_Five
*/

String paletteFileName = "selected";
ArrayList<Boid> boids = new ArrayList<Boid>();
boolean pause;
float hueOffset;

ArrayList<Palette> palettes;
Palette currentPalette;

float strokeWidthFromDist = 0;
float strokeWidthToDist = 200;
float strokeWidthFrom = 3;
float strokeWidthTo = 6;
float strokeAlphaFromDist = strokeWidthFromDist;
float strokeAlphaToDist = strokeWidthToDist;
float strokeAlphaFrom = 0;
float strokeAlphaTo = 1;
float targetRandomAssignThreshold = 15;
float deathThreshold = 100;
float deathSpeed = 0;
int steps = 200;

float maxSpeedMin = 5;
float maxSpeedMax = maxSpeedMin * 2;
float maxForce = 0.2;
float maxSpeedDecay = 1;

void setup()
{
  size(768, 768, P2D);
  blendMode(ADD);
  //colorMode(HSB, 360, 100, 100, 255);

  if (palettes == null)
  {
    palettes = new ArrayList<Palette>();
    loadPalettes();
  }
  
  reset(false);
}

void keyPressed()
{
  if ((key == 'a') || (key == 's'))
  {
    reset(key == 'a');
    for (int i = 0; i < steps; i++)
    {
      draw();
    }
    pause = true;
  }
  if (key == ' ')
  {
    System.out.println(currentPalette.name);
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(false);
  }
  else if (mouseButton == CENTER)
  {
    pause = false;
    for (int i = 0; i < steps; i++)
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

void reset(boolean keepHue)
{
  if (!keepHue)
  {
    int paletteIndex = (int)random(palettes.size());
    currentPalette = palettes.get(paletteIndex);
  }
  
  boids.clear();
  for (int i = 0; i < 100; i++)
  {
    boids.add(new Boid(new PVector(random(0, width), random(0, height))));
  }

  background(0);
  //stroke(140, 1);
  stroke(255, 5);
  //stroke(255);
  
  pause = false;
}

void draw()
{
  if (pause)
    return;
  
  strokeWeight(2);
  //stroke(255, min((frameCount / 15), 20));
  //background(0);
  for (Boid boid : boids)
  {
    boid.update();
    boid.draw();
  }
}

void loadPalettes()
{
  XML xml = loadXML(paletteFileName + ".xml");
  XML[] children = xml.getChildren("palette");
  for (XML child : children)
  {
    Palette palette = new Palette();
    XML[] xcolors = child.getChild("colors").getChildren("hex");
    String[] widths = child.getChild("colorWidths").getContent().split(",");
    String title = child.getChild("title").getContent();
    palette.name = title;//.substring(10, title.length()-10-3);
    int i = 0;
    for(XML xcolor : xcolors)
    {
      color c = unhex("FF" + xcolor.getContent());
      float w = Float.parseFloat(widths[i]);
      i++;
      palette.addColor(c, w);
    }
    
    palettes.add(palette);
  } 
}

class Boid
{
  PVector velocity;
  PVector position;
  PVector previousPosition;
  float index;
  int colorIndex;
  int c;
  Boid targetBoid;
  ArrayList<Boid> closest = new ArrayList<Boid>();
  float death = 0;
  float maxSpeed;
  float maxSpeedMultiplier = 1;
  
  Boid(PVector position)
  {
    this.position = position;
    this.velocity = new PVector();
    
    assignRandomColorIndex();
    
    PVector delta = new PVector(width / 2 - position.x, height / 2 - position.y);
    delta.normalize();
    if ((delta.x == 0) && (delta.y == 0))
    {
      delta.x = 1;
    }
    
    //angle = atan2(delta.y, delta.x);
    //velocity = PVector.mult(delta, maxSpeed);
    
    /*
    while ((position.x > 0) && (position.x < width) &&
           (position.y > 0) && (position.y < height))
    {
      position.x -= delta.x;
      position.y -= delta.y;
    }
    */
    
    previousPosition = new PVector(position.x, position.y);
    
    index = random(0, 1000000);
    
    //hue = (360 + angle * RAD_TO_DEG) % 360;
    //hue = (hueOffset + random(-1, 1) * 10 + 360) % 360;
    
  }
  
  void assignRandomColorIndex()
  {
    colorIndex = (int)random(0, currentPalette.colors.size());
    c = currentPalette.colors.get(colorIndex);
    targetBoid = null;
    maxSpeed = random(maxSpeedMin, maxSpeedMax);
    maxSpeed *= maxSpeedMultiplier;
  }
  
  boolean update()
  {
    if (death >= 1)
      return false;
      
    maxSpeedMultiplier *= maxSpeedDecay;
    
    /*
    if (closest.size() == 0)
    {
      float neighborDistance = 300;
      for (Boid boid : boids)
      {
        if (boid == this)
          continue;
        
        float dist = PVector.dist(boid.position, position);
        if (dist > neighborDistance)
          continue;
  
        closest.add(boid);
      }
    }
    */

    if (targetBoid == null)
    {
      float closestDist = 0;
      for (Boid boid : boids)
      {
        if (boid == this) continue;
        //if (boid.targetBoid != null) continue;
        if (boid.colorIndex != colorIndex) continue;
        
        float dist = PVector.dist(boid.position, position);
        if ((targetBoid == null) || (dist < closestDist))
        {
          targetBoid = boid;
          closestDist = dist;
        }
      }
      
      //if ((random(0, 1) > 0.8) && (targetBoid != null)) targetBoid.targetBoid = this;
    }
    
    if (targetBoid == null)
    {
      //assignRandomColorIndex();
      return true;
    }
    
    PVector delta = PVector.sub(targetBoid.position, position);
    float distance = delta.mag();
    if (distance <= targetRandomAssignThreshold)
    {
      assignRandomColorIndex();
      return true;
    }
    else if (distance <= deathThreshold)
    {
      death += deathSpeed;
    }
    
    //PVector sep = separate();
    //PVector ali = align();
    //PVector coh = cohesion();
    //PVector wan = wander();
    
    //sep.mult(25.5);
    //ali.mult(1);
    //coh.mult(1);
    //wan.mult(1.5);
    
    //velocity.add(sep);
    //velocity.add(ali);
    //velocity.add(coh);
    //velocity.add(wan);
    
    delta.normalize();
    delta.mult(distance * 0.1);
    velocity.add(delta);
    velocity.limit(maxSpeed);
    
    position.add(velocity);
    return true;
  }
  
  void draw()
  {
    if (death >= 1)
      return;
    /*
    stroke(c);
    
    float neighborDistance = 150;
    float closenessSum = 0;
    int count = 0;
    float averageHue = 0;
    for (Boid boid : boids)
    {
      if (boid == this)
        continue;
      
      float dist = PVector.dist(boid.position, position);
      if (dist > neighborDistance)
        continue;

      float closeness = 1 - (dist / neighborDistance);
      closenessSum += closeness;
      count++;
      
      //stroke(hue, 100, 100, closeness * 2);
      //line(position.x, position.y, boid.position.x, boid.position.y);
      
      averageHue += boid.hue;
      //hue = ((hue + deltaAngle(hue, boid.hue) * closeness * 0.01) + 360) % 360;
    }
    
    if (count > 0)
    {
      averageHue = averageHue / count;
      //hue = ((hue + deltaAngle(hue, averageHue) * 0.01) + 360) % 360;
      //hue = lerpHue(hue, averageHue, 0.01);
    }
    
    float distanceToCenter = PVector.dist(position, new PVector(width / 2, height / 2));
    float smallerSide = min(width, height);
    float distanceToCenterPercent = min(distanceToCenter / (smallerSide / 2), 1);
    float closenessToCenterPercent = 1 - distanceToCenterPercent;
    */
    
    /*
    for (int i = 0; i < 6; i++)
    {
      float offsetPercent = random(0, 1);
      float offsetDistance = offsetPercent * 6;
      float offsetAngle = random(0, PI * 2);
      PVector offset = new PVector(cos(angle) * offsetDistance, sin(angle) * offsetAngle);
      //strokeWeight(min(closenessSum / 2, 3));
      strokeWeight(1);
      stroke(hue, 100, 100, closenessSum * 3);
      point(position.x + offset.x, position.y + offset.y);
    }
    */

    //strokeWeight(min(closenessSum / 2, 3));
    //stroke(hue, 100, 100, closenessSum * 3);

    if (targetBoid == null)
      return;
      
    PVector delta = PVector.sub(targetBoid.position, position);
    float distance = delta.mag();

    float alpha = 255 * mapClamp(distance, strokeAlphaFromDist, strokeAlphaToDist, strokeAlphaFrom, strokeAlphaTo);
    float weight = mapClamp(distance, strokeWidthFromDist, strokeWidthToDist, strokeWidthFrom, strokeWidthTo);

    strokeWeight(weight);
    //fill(c, alpha);
    //noStroke();
    
    //ellipse(position.x, position.y, weight * 2, weight * 2);
    //strokeWeight(2);
    stroke(c, alpha);
    line(previousPosition.x, previousPosition.y, position.x, position.y);
  /*
    int pointCount = (int)(16 * weight);
    for (int i = 0; i < pointCount; i++)
    {
      float offsetPercent = random(0, 1);
      float offsetDistance = offsetPercent * weight;
      float offsetAngle = random(0, PI * 2);
      PVector offset = new PVector(cos(offsetAngle) * offsetDistance, sin(offsetAngle) * offsetDistance);
      //strokeWeight(min(closenessSum / 2, 3));
      stroke(c, alpha * (1-offsetPercent));
      strokeWeight(1);
      float x = lerp(previousPosition.x, position.x, (float)i/pointCount);
      float y = lerp(previousPosition.y, position.y, (float)i/pointCount);
      point(x + offset.x, y + offset.y);
    }
*/
    previousPosition.x = position.x;
    previousPosition.y = position.y;
  }
  
  float lerpHue(float h1, float h2, float amt)
  {
     // figure out shortest direction around hue
     float z = 360;
     float dh12 = (h1>=h2) ? h1-h2 : z-h2+h1;
     float dh21 = (h2>=h1) ? h2-h1 : z-h1+h2;
     float h = (dh21 < dh12) ? h1 + dh21 * amt : h1 - dh12 * amt;
     if (h < 0.0) h += z;
     else if (h > z) h -= z;
     return h;
  }
  
  /*
  float deltaAngle(float a, float b)
  {
    float delta = b - a;
    while (delta < 0)
    {
      delta += 360;
    }
    
    delta %= 360;
    
    if (delta > 180)
      delta = 180 - delta;
    
    return delta;
  }
  */

  /*
  PVector wander()
  {
    angle += lerp(-1, 1, noise(index + frameCount * 0.001)) * 0.1;

    PVector dir = new PVector(cos(angle) * maxSpeed, sin(angle) * maxSpeed);
    
    PVector steer = PVector.sub(dir, velocity);
    steer.limit(maxForce);
    return steer;
  }
  */

  PVector separate()
  {
    float neighborDistance = 50;
    PVector sum = new PVector();
    int count = 0;
    for (Boid boid : closest)
    {
      if (boid == this)
        continue;
      
      //if (PVector.dist(boid.position, position) > neighborDistance)
      //  continue;
      
      PVector delta = PVector.sub(position, boid.position);
      
      delta.normalize();
      delta.div(delta.mag());
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
    for (Boid boid : closest)
    {
      if (boid == this)
        continue;
      
      //if (PVector.dist(boid.position, position) > neighborDistance)
      //  continue;
        
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
    for (Boid boid : closest)
    {
      if (boid == this)
        continue;
      
      //if (PVector.dist(boid.position, position) > neighborDistance)
      //  continue;

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

class Palette
{
  ArrayList<Integer> colors = new ArrayList<Integer>();
  ArrayList<Float> widths = new ArrayList<Float>();
  float totalWidth = 0;
  String name;
  
  void addColor(color c, float w)
  {
    colors.add(c);
    widths.add(w);
    totalWidth += w;
  }
  
  color randomColor()
  {
    if (colors.size() == 0)
      return color(0, 0, 0, 0);
    
    float value = random(totalWidth);
    int index = 0;
    while ((index + 1) < colors.size())
    {
      float currentWidth = widths.get(index);
      if (value < currentWidth)
        break;

      value -= widths.get(index);
      index++;
    }
    
    return colors.get(index);
  }
}

float mapClamp(float value, float start1, float stop1, float start2, float stop2)
{
  value = max(start1, min(value, stop1));
  return map(value, start1, stop1, start2, stop2);
}