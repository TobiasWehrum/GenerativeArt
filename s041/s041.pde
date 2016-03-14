/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to refresh, but keep color scheme.

Color schemes:
- "(◕ ” ◕)" by sugar!: http://www.colourlovers.com/palette/848743
- "vivacious" by plch: http://www.colourlovers.com/palette/557539/vivacious
- "Sweet Lolly" by nekoyo: http://www.colourlovers.com/palette/56122/Sweet_Lolly
- "Pop Is Everything" by jen_savage: http://www.colourlovers.com/palette/7315/Pop_Is_Everything
- "it's raining love" by tvr: http://www.colourlovers.com/palette/845564/its_raining_love
- "A Dream in Color" by madmod001: http://www.colourlovers.com/palette/871636/A_Dream_in_Color
- "Influenza" by Miaka: http://www.colourlovers.com/palette/301154/Influenza
- "Ocean Five" by DESIGNJUNKEE: http://www.colourlovers.com/palette/1473/Ocean_Five
*/

String paletteFileName = "selected2";

float scale = 1;
int steps = 200;
boolean pause = false;
boolean ignoreWidth = true;

ArrayList<Palette> palettes = new ArrayList<Palette>();
Palette currentPalette;

ArrayList<Integer> chosenColors;

void setup()
{
  int originalWidth = 768;
  int originalHeight = 768;
  int desiredWidth = 768;
  int desiredHeight = 768;
  size(768, 768, P2D);
  //fullScreen(P2D);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
  
  blendMode(ADD);

  //scaledSize(768, 768, displayWidth, displayHeight);

  loadPalettes();

  reset(false);
}
/*
void keyPressed()
{
  if ((key == 'a') || (key == 's'))
  {
    reset(key == 'a');
    drawLoop();
    pause = true;
  }
  if (key == ' ')
  {
    System.out.println(currentPalette.name);
  }
}

void drawLoop()
{
  for (int i = 0; i < steps; i++)
  {
    draw();
  }
}
*/
void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(false);
  }
  else if (mouseButton == CENTER)
  {
  }
  else if (mouseButton == RIGHT)
  {
    //pause = !pause;
    reset(true);
  }
}

void reset(boolean keepHue)
{
  if (!keepHue)
  {
    int paletteIndex = (int)random(palettes.size());
    currentPalette = palettes.get(paletteIndex);
    ArrayList<Integer> colors = currentPalette.colors;
    chosenColors = new ArrayList<Integer>();
    chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
    chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
    if (random(1) > 0.5)
      chosenColors = colors;
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
  
  background(0);
  
  //randomSeed(0);
  
  //for (int i = 0; i < 10; i++)
  //  drawStar(random(0.2, 0.5));
  drawGraph();
    
  pause = true;
}

void drawGraph()
{
  int factor = 1;//(int)random(5, 20)*10;
  float radiusMin = 100;
  float radiusMax = 350;
  radiusMin = radiusMax = height/3;
  int stepsFrom = 1;
  int stepsTo = 15;
  ArrayList<Pendulum> pendulums = new ArrayList<Pendulum>();
  for (int i = 0; i < 4; i++)
  {
    int steps = factor * (int)random(stepsFrom, stepsTo+1);
    if (i == 0)
    {
      pendulums.add(new PendulumDirectional(steps, new PVector(radiusMax, 0)));//randomDirectionRadius(random(radiusMin, radiusMax))));
    }
    else if (i == 1)
    {
      pendulums.add(new PendulumDirectional(steps, new PVector(0, radiusMax)));//randomDirectionRadius(random(radiusMin, radiusMax))));
    }
    else if (i == 2)
    {
      pendulums.add(new PendulumRotate(steps));
    }
    else if (i == 3)
    {
      float from = 0;
      float to = 1;
      if (random(1) > 0.5)
        pendulums.add(new PendulumScale(steps, from, to));
    }
  }
  
  long stepCount = 0;
  boolean allPendulumsZero;
  do
  {
    stepCount++;
    allPendulumsZero = true;
    for (Pendulum pendulum : pendulums)
    {
      pendulum.currentStep = (pendulum.currentStep + 1) % pendulum.steps;
      allPendulumsZero &= pendulum.isZero();
    }
  } while (!allPendulumsZero);
  
  float p = random(0, 1);
  int desiredCount = (int)lerp(10000, 20000, p);
  factor = ceil(desiredCount/stepCount);
  //factor = (int)random(100, 200);
  if (factor > 1)
  {
    for (Pendulum pendulum : pendulums)
    {
      pendulum.steps *= factor;
    }
  }
  
  color c = currentPalette.randomColor();
  float a = lerp(random(50, 100), random(1, 20), p)/4;
  //a = 100;
  //fill(c, a);
  noFill();
  //stroke(50);
  stroke(c, a); //(int)random(10, 100));
  //noStroke();

  strokeWeight(3);
  //Pendulum pendulumSize = new PendulumRotate(factor*(int)random(stepsFrom, stepsTo+1));
  
  //beginShape();
  //vertex(width/2, height/2);
  do
  {
    allPendulumsZero = true;
    PVector position = new PVector(0, 0);
    for (Pendulum pendulum : pendulums)
    {
      position = pendulum.step(position);
      allPendulumsZero &= pendulum.isZero();
    }
    float x = width/2 + position.x;
    float y = height/2 + position.y;
    //vertex(x, y);
    //float size = 1 + position.mag()/100;
    //float size = lerp(5, 1, position.mag()/width/2);
    //strokeWeight(size);
    //pendulumSize.step(position);
    //float size = lerp(2, 20, pendulumSize.currentPercentSinHalf());
    //System.out.println(size);
    
    //fill(c, a); noStroke();
    //ellipse(x, y, size, size);
    
    /*
    PVector lineEnd = new PVector(position.x, position.y);
    float distance = lineEnd.mag();
    lineEnd.mult((distance-size/2)/distance);
    x = width/2 + lineEnd.x; 
    y = height/2 + lineEnd.y;
    */

    stroke(c, a); noFill();
    line(width/2, height/2, x, y);
    /*
    line(0, 0, x, y);
    line(width, 0, x, y);
    line(0, height, x, y);
    line(width, height, x, y);
    */
    
    //allPendulumsZero &= pendulumSize.isZero();
  } while (!allPendulumsZero);
  
  //endShape();

  strokeWeight(1);

  //c = currentPalette.randomColor();
  stroke(c, 30);

  beginShape();
  vertex(width/2, height/2);
  do
  {
    allPendulumsZero = true;
    PVector position = new PVector(0, 0);
    for (Pendulum pendulum : pendulums)
    {
      position = pendulum.step(position);
      allPendulumsZero &= pendulum.isZero();
    }
    float x = width/2 + position.x;
    float y = height/2 + position.y;
    //float size = 1 + position.mag()/100;
    //float size = 10 - position.mag()/100;
    //strokeWeight(size);
    vertex(x, y);
  } while (!allPendulumsZero);
  endShape();
}

PVector randomDirectionStep(float maxDistance)
{
  return new PVector(random(-maxDistance, maxDistance), random(-maxDistance, maxDistance));
}

PVector randomDirectionRadius(float radius)
{
  float angle = random(0, PI*2);
  return new PVector(cos(angle) * radius, sin(angle) * radius);
}

abstract class Pendulum
{
  public int steps;
  public int currentStep;
  
  public Pendulum(int steps)
  {
    this.steps = steps;
  }
  
  public PVector step(PVector position)
  {
    currentStep = (currentStep+1) % steps;
    return result(position);
  }
  
  protected abstract PVector result(PVector position);
  
  public boolean isZero()
  {
    return currentStep == 0;
  }
  
  public float currentPercent()
  {
    return (float)currentStep / steps;
  }
  
  public float currentPercentSin()
  {
    return sin(currentPercent() * PI * 2);
  }

  public float currentPercentSinHalf()
  {
    return sin(currentPercent() * PI);
  }
}

class PendulumDirectional extends Pendulum
{
  public PVector delta;
  
  public PendulumDirectional(int steps, PVector delta)
  {
    super(steps);
    this.delta = delta;
  }
  
  @Override
  protected PVector result(PVector position)
  {
    /*
    percent *= 4;
    if (percent > 3)
    {
      percent = -1 + (percent-3);
    }
    else if (percent > 2)
    {
      percent = -(percent-2);
    }
    else if (percent > 1)
    {
      percent = 1 - (percent-1);
    }
    */
    
    float percent = currentPercentSin();
    return PVector.add(position, new PVector(delta.x * percent, delta.y * percent));
  }
}

class PendulumRotate extends Pendulum
{
  public PendulumRotate(int steps)
  {
    super(steps);
  }
  
  @Override
  protected PVector result(PVector position)
  {
    float percent = currentPercent();
    float distance = position.mag();
    float angle = atan2(position.y, position.x) + percent * PI * 2;
    return new PVector(cos(angle) * distance, sin(angle) * distance);
  }
}

class PendulumScale extends Pendulum
{
  float from;
  float to;
  
  public PendulumScale(int steps, float from, float to)
  {
    super(steps);
    this.from = from;
    this.to = to;
  }
  
  @Override
  protected PVector result(PVector position)
  {
    float percent = currentPercentSin();
    float distance = position.mag() * lerp(from, to, percent);
    float angle = atan2(position.y, position.x);
    return new PVector(cos(angle) * distance, sin(angle) * distance);
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