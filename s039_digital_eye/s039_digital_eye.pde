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
  drawStar(1);
    
  pause = true;
}

void drawStar(float radiusScale)
{
  strokeWeight(1);
  int count = (int)random(5, 15);
  float angleFrom = random(-PI*2, PI*2);
  int x = width/2;
  int y = height/2;
  //x = (int)random(0, width);
  //y = (int)random(0, height);
  for (int i = 0; i < count; i++)
  {
    stroke(chosenColors.get((int)random(0, chosenColors.size())), random(50, 200));
    //angleFrom = random(-PI/2, PI/2);
    
    //float angleTo = angleFrom + random(-PI/2, PI/2);
    float angleTo = angleFrom + random(PI/4, PI);
    float radius = random(height/5, height/2) * radiusScale;
    int stepCount = (int)(abs(angleTo-angleFrom)*random(50, 200));
    float innerRadius = sqrt(random(0, 1));
    drawCircle(x, y, angleFrom, angleTo, radius, radius, stepCount, innerRadius);
    
    angleFrom = angleTo;
  }
}

void drawCircle(float x, float y, float angleFrom, float angleTo, float radiusFrom, float radiusTo, int stepCount,
                float innerRadius)
{
  float angleDelta = (angleTo-angleFrom) / (stepCount-1);
  float radiusDelta = (radiusTo-radiusFrom) / (stepCount-1);
  
  for (int i = 0; i < stepCount; i++)
  {
    float angle = angleFrom + angleDelta * i;
    float radius = radiusFrom + radiusDelta * i;

    float dx = cos(angle) * radius;
    float dy = sin(angle) * radius;
    
    if (innerRadius == 0)
    {
      line(x-dx, y-dy, x+dx, y+dy);
    }
    else
    {
      float dx2 = dx*innerRadius;
      float dy2 = dy*innerRadius;
      line(x-dx, y-dy, x-dx2, y-dy2);
      line(x+dx, y+dy, x+dx2, y+dy2);
    }
    //line(x, y, x+dx, y+dy);
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