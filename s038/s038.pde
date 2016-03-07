/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to finish the current painting, or a new one if the current one is already finished.
- Right-click to pause/unpause.
- A to refresh and finish a new painting with same color scheme.
- S to refresh and finish a new painting with changed color scheme.

Color schemes:
- "Hymn For My Soul" by faded jeans: http://www.colourlovers.com/palette/81885/Hymn_For_My_Soul
- "s e x ' n . r o l l " by tvr: http://www.colourlovers.com/palette/401946/s_e_x_n_._r_o_l_l
- "fresh cut day" by electrikmonk: http://www.colourlovers.com/palette/46688/fresh_cut_day
- "(◕ ” ◕)" by sugar!: http://www.colourlovers.com/palette/848743
- "vivacious" by plch: http://www.colourlovers.com/palette/557539/vivacious
- "Sweet Lolly" by nekoyo: http://www.colourlovers.com/palette/56122/Sweet_Lolly
- "Pop Is Everything" by jen_savage: http://www.colourlovers.com/palette/7315/Pop_Is_Everything
- "it's raining love" by tvr: http://www.colourlovers.com/palette/845564/its_raining_love
- "A Dream in Color" by madmod001: http://www.colourlovers.com/palette/871636/A_Dream_in_Color
- "Influenza" by Miaka: http://www.colourlovers.com/palette/301154/Influenza
- "Ocean Five" by DESIGNJUNKEE: http://www.colourlovers.com/palette/1473/Ocean_Five
*/

String paletteFileName = "selected";
ArrayList<Boid> boids = new ArrayList<Boid>();
ArrayList<Star> stars = new ArrayList<Star>();
boolean pause;
float hueOffset;

int boidCountMin = 15;
int boidCountMax = boidCountMin + 35;
int starCountMin = 5;
int starCountMax = starCountMin + 15;

boolean ignoreWidth = true;

ArrayList<Palette> palettes;
Palette currentPalette;

int steps = 200;

float maxSpeedMin = 5;
float maxSpeedMax = maxSpeedMin * 2;
float maxSpeedDecay = 1;

int mode = 0;

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
    drawUntilDead();
    pause = true;
  }
  if (key == ' ')
  {
    System.out.println(currentPalette.name);
  }
}

void drawUntilDead()
{
  while (boids.size() > 0)
  {
    draw();
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
    if (boids.size() == 0)
      reset(false);
      
    pause = false;
    drawUntilDead();
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
  
  mode = (int)random(0, 2);
}

void draw()
{
  if (pause || boids.size() == 0)
    return;
  
  loadPixels();
  strokeWeight(2);
  //stroke(255, min((frameCount / 15), 20));
  //background(0);
  boolean anyBoidAlive = false;
  for (Boid boid : boids)
  {
    boid.update();
    boid.draw();
    if (!boid.dead)
      anyBoidAlive = true;
  }
  
  if (!anyBoidAlive)
  {
    /*
    background(0);
    for (Boid boid : boids)
    {
      boid.finalDraw();
    }
    */
    boids.clear();
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
    String[] widths = null;
    if (!ignoreWidth)
      widths = child.getChild("colorWidths").getContent().split(",");
    String title = child.getChild("title").getContent();
    palette.name = title;//.substring(10, title.length()-10-3);
    int i = 0;
    for(XML xcolor : xcolors)
    {
      color c = unhex("FF" + xcolor.getContent());
      float w = 1;
      if (widths != null)
        w = Float.parseFloat(widths[i]);
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
  boolean dead;
  float maxSpeed;
  float maxSpeedMultiplier = 1;
  float jumpWidth;
  boolean jumpScaleToDistance;
  ArrayList<PVector> positions = new ArrayList<PVector>();
  
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
    
    while ((position.x > 0) && (position.x < width) &&
           (position.y > 0) && (position.y < height))
    {
      position.x -= delta.x;
      position.y -= delta.y;
    }
    
    previousPosition = new PVector(position.x, position.y);
    
    index = random(0, 1000000);
    
    jumpWidth = random(1, 100);
    jumpScaleToDistance = true;
    //jumpWidth = 10;
    //jumpWidth = PI + 0.01;
    //jumpScaleToDistance = false;
    
    //if (random(1) > 0.5) jumpWidth *= -1;
    positions.add(position);
  }
  
  PVector getAngle(PVector center, PVector from, PVector to, float addAngle, boolean divideByDistance)
  {
    PVector delta = PVector.sub(to, from);
    float distance = delta.mag();
    delta.div(distance);
    
    //distance--;
    
    float currentAngle = atan2(delta.y, delta.x);
    
    float angleSpeed = addAngle;
    if (divideByDistance && (distance > 0.1))
      angleSpeed /= distance;

    float newAngle = currentAngle + angleSpeed;
    
    return PVector.add(center, new PVector(cos(newAngle)*distance, sin(newAngle)*distance));
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
    
    //previousPosition = getAngle(closestStar.position, closestStar.position, previousPosition, -15, true);
    if (mode == 0)
    {
      position = getAngle(closestStar.position, closestStar.position, position, jumpWidth, jumpScaleToDistance);
    }
    else
    {
      position = getAngle(closestStar.position, position, closestStar.position, 180.01, false);
    }

    //positions.add(position);
    
    /*
    PVector deltaToClosestStar = PVector.sub(closestStar.position, position);
    float distanceToClosestStar = deltaToClosestStar.mag();
    deltaToClosestStar.div(distanceToClosestStar);
    
    float currentAngle = atan2(deltaToClosestStar.y, deltaToClosestStar.x);
    
    float angleSpeed = jumpWidth / distanceToClosestStar;
    angleSpeed = 180.01;
    float newAngle1 = currentAngle - angleSpeed;
    float newAngle2 = currentAngle + angleSpeed;
    
    PVector newPos1 = PVector.add(closestStar.position, new PVector(cos(newAngle1)*distanceToClosestStar,
                                                                    sin(newAngle1)*distanceToClosestStar));
    PVector newPos2 = PVector.add(closestStar.position, new PVector(cos(newAngle2)*distanceToClosestStar,
                                                                    sin(newAngle2)*distanceToClosestStar));
    previousPosition = newPos1;
    position = newPos2;
    */
    
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
    
    float weight = 2;
    float alpha = 200;

    strokeWeight(weight);
    stroke(c, alpha);
    line(previousPosition.x, previousPosition.y, position.x, position.y);
/*
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
*/
/*
    int pointCount = (int)(32 * weight);
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
  
  void finalDraw()
  {
    float weight = 2;
    float alpha = 200;

    noFill();
    beginShape();
    strokeWeight(weight);
    stroke(c, alpha);
    for (PVector pos : positions)
      vertex(pos.x, pos.y);
    endShape();
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