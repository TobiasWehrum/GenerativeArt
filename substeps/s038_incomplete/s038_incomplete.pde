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
ArrayList<Star> stars = new ArrayList<Star>();
boolean pause;
float hueOffset;

int boidCountMin = 10;
int boidCountMax = boidCountMin + 30;
int starCountMin = 5;
int starCountMax = starCountMin + 15;

ArrayList<Palette> palettes;
Palette currentPalette;

int steps = 200;

float maxSpeedMin = 5;
float maxSpeedMax = maxSpeedMin * 2;
float maxSpeedDecay = 1;

void setup()
{
  size(768, 768, P2D);
  //blendMode(ADD);
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
  
  int boidCount = (int) random(boidCountMin, boidCountMax + 1);
  boids.clear();
  for (int i = 0; i < boidCount; i++)
  {
    boids.add(new Boid(new PVector(random(0, width), random(0, height))));
  }

  int starCount = (int) random(starCountMin, starCountMax + 1);
  stars.clear();
  for (int i = 0; i < starCount; i++)
  {
    stars.add(new Star(new PVector(random(0, width), random(0, height))));
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
  
  loadPixels();
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

class Star
{
  PVector position;
  
  Star(PVector position)
  {
    this.position = position;
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
  ArrayList<Boid> closest = new ArrayList<Boid>();
  boolean dead;
  float maxSpeed;
  float maxSpeedMultiplier = 1;
  
  Boid(PVector position)
  {
    this.position = position;
    this.velocity = new PVector();
    
    colorIndex = (int)random(0, currentPalette.colors.size());
    c = currentPalette.colors.get(colorIndex);
    maxSpeed = random(maxSpeedMin, maxSpeedMax);
    maxSpeed *= maxSpeedMultiplier;
    
    PVector delta = new PVector(width / 2 - position.x, height / 2 - position.y);
    delta.normalize();
    if ((delta.x == 0) && (delta.y == 0))
    {
      delta.x = 1;
    }
    
    velocity = PVector.mult(delta, maxSpeed);
    
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
  }
  
  boolean update()
  {
    if (dead)
      return false;
    
    Star closestStar = null;
    float closestDistance = Float.MAX_VALUE;
    
    for (Star star : stars)
    {
      float distance = PVector.dist(star.position, position);
      if (distance < closestDistance)
      {
        closestDistance = distance;
        closestStar = star;
      }
    }
    
    PVector deltaToClosestStar = PVector.sub(closestStar.position, position);
    float distanceToClosestStar = deltaToClosestStar.mag();
    deltaToClosestStar.div(distanceToClosestStar);
    
    float currentAngle = atan2(deltaToClosestStar.y, deltaToClosestStar.x);
    
    float angleSpeed = distanceToClosestStar * 0.1;
    float newAngle1 = currentAngle - angleSpeed;
    float newAngle2 = currentAngle + angleSpeed;
    
    PVector newPos1 = PVector.add(closestStar.position, new PVector(cos(newAngle1)*distanceToClosestStar,
                                                                    sin(newAngle1)*distanceToClosestStar));
    PVector newPos2 = PVector.add(closestStar.position, new PVector(cos(newAngle2)*distanceToClosestStar,
                                                                    sin(newAngle2)*distanceToClosestStar));
    
    position = newPos2;
    
    //velocity.add(deltaToClosestStar.mult(1f));
    
    //velocity.normalize();
    //velocity.mult(4f);
    
    //position.add(velocity);
    
    int pixelIndex = clamp(((int)position.x) + ((int)position.y) * width, 0, width*height-1);
    color c = pixels[pixelIndex]; 
    if (brightness(c) != 0)
      dead = true;
    
    return true;
  }
  
  void draw()
  {
    if (dead)
      return;
    
    float weight = 10;
    float alpha = 10;
      
    strokeWeight(weight);
    stroke(c, alpha);
    line(previousPosition.x, previousPosition.y, position.x, position.y);
    
    weight = 5;
    alpha = 60;
      
    strokeWeight(weight);
    stroke(c, alpha);
    line(previousPosition.x, previousPosition.y, position.x, position.y);

    weight = 1;
    alpha = 255;
      
    strokeWeight(weight);
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

int clamp(int value, int min, int max)
{
  return max(min, min(value, max));
}

float mapClamp(float value, float start1, float stop1, float start2, float stop2)
{
  value = max(start1, min(value, stop1));
  return map(value, start1, stop1, start2, stop2);
}