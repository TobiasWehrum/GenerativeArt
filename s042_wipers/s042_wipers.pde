/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to draw 200 steps and pause.
- Right-click to pause/resume.
- A to reset and draw 200 steps with the current color scheme (and then pause).
- B to reset and draw 200 steps with another color scheme (and then pause).

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

float angleChangeRate = 0.01f;
float angleChangeSpeed = 0.5f;
float positionChangeRate = 0.01f;
float positionChangeSpeed = 2f;
float alpha = 10;
int wiperCountMin = 10;
int wiperCountMax = wiperCountMin;

boolean useLocking;
boolean wrap;

float scale = 1;
int steps = 2000;
boolean pause = false;
boolean ignoreWidth = true;
int frameNumber;

ArrayList<Palette> palettes = new ArrayList<Palette>();
Palette currentPalette;

ArrayList<Wiper> wipers = new ArrayList<Wiper>();
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

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(false);
  }
  else if (mouseButton == CENTER)
  {
    pause = false;
    drawLoop();
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
    ArrayList<Integer> colors = currentPalette.colors;
    chosenColors = new ArrayList<Integer>();
    chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
    chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
    if (random(1) > 0.5)
      chosenColors = colors;
  }
  
  wipers.clear();
  int count = (int)random(wiperCountMin, wiperCountMax+1);
  for (int i = 0; i < count; i++)
  {
    //randomSeed(seed);
    wipers.add(new Wiper());
  }
  
  noiseSeed((int)random(0, 100000000));
  
  /*
  for (Wiper wiper : wipers)
  {
    wiper.position = new PVector(random(0, width), random(0, height));
  }
  */
  
  background(0);
  //stroke(140, 1);
  //stroke(255, 5);
  //stroke(255);
  strokeWeight(1);
  
  pause = false;
  frameNumber = 0;
  
  useLocking = random(1) < 0.5;
  wrap = random(1) < 0.5;
}

void draw()
{
  if (pause)
    return;
  
  frameNumber++;
  
  //background(0);
  
  //randomSeed(0);
  for (Wiper wiper : wipers)
    wiper.update();
    
  //pause = true;
}

class Wiper
{
  PVector position;
  int r;
  float length;
  float angle;
  color c;
  boolean locked;
  
  Wiper()
  {
    position = new PVector(random(0, width), random(0, height));
    r = (int)random(0, 1000000000);
    length = random(100, 300);
    c = chosenColors.get(0);
    angle = random(0, PI*2);
    locked = useLocking && (random(1) < 0.5);
  }
  
  void update()
  {
    int f = frameNumber;
    if (locked)
      f = 0;
      
    angle += (noise(f * angleChangeRate, 0, r)*2-1) * angleChangeSpeed;
    position.x += (noise(f * positionChangeRate, 1, r)*2-1) * positionChangeSpeed;
    position.y += (noise(f * positionChangeRate, 2, r)*2-1) * positionChangeSpeed;
    
    if (wrap)
    {
      if (position.x < 0) position.x = position.x + width;
      if (position.x > width) position.x = position.x - width;
      if (position.y < 0) position.y = position.y + height;
      if (position.y > height) position.y = position.y - height;
    }
    else
    {
      position.x = clamp(position.x, 0, width);
      position.y = clamp(position.y, 0, height);
    }
    
    float x1 = position.x;
    float y1 = position.y;
    float x2 = x1 + cos(angle) * length;
    float y2 = y1 + sin(angle) * length;
    
    stroke(c, alpha);
    line(x1, y1, x2, y2);
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

float clamp(float value, float min, float max)
{
  return max(min, min(value, max));
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