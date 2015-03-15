/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to pause/resume.
*/

// Palettes from:
// - http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1&numResults=100
// - http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1&numResults=100&keywords=mondrian
// - http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1&numResults=10&keywords=mondrian

String paletteFileName = "top100";

int layers = 4;
int childCount = 4;
float speed = 1;
float radiusPerLayerMin = 5;
float radiusPerLayerMax = 20;
float extraDistancePerLayerMin = 5;
float extraDistancePerLayerMax = 15;
float alpha = 20;
int backgroundColor = 255;

int frameCountCap = 1000;
boolean paused = false;

ArrayList<Palette> palettes;
Palette currentPalette;

int seed;

void setup()
{
  size(500, 500);
  smooth();
  
  paused = false;
  
  seed = (int) random(100000);
  randomSeed(seed);
  noiseSeed(seed);
  
  if (palettes == null)
  {
    palettes = new ArrayList<Palette>();
    loadPalettes();
  }
  
  int paletteIndex = (int)random(palettes.size());
  currentPalette = palettes.get(paletteIndex);
  
  frameCount = 0;
  
  background(255);
}


void draw()
{
  if (paused)
  {
    frameCount--;
    return;
  }
  
  randomSeed(seed);
  if (alpha == 255)
  {
    background(backgroundColor);
  }
  else
  {
    fill(backgroundColor, alpha);
    noStroke();
    rect(0, 0, width, height);
  }
  drawCircle(layers, width / 2, height / 2, width / 2, height / 2, getRadius(layers), getFillColor());
}

void drawCircle(int layer, float x, float y, float px, float py, float radius, color c)
{
  //stroke(0, 0, 0);
  //noStroke();
  //stroke(c);
  //fill(c);
  
  if (layer != layers)
  {
    //ellipse(x, y, radius * 2, radius * 2);
    //stroke(0, 0, 0, 5);
    //strokeWeight(radius + 4);
    //line(x, y, px, py);
    //strokeCap(PROJECT);
    
    stroke(c);
    strokeWeight(radius);
    line(x, y, px, py);
    /*
    if (frameCount <= frameCountCap)
    {
      line(x, y, px, py);
    }
    else
    {
      PVector delta = new PVector(x - px, y - py);
      float deltaMagnitude = delta.mag();
      delta.normalize();
      float newLength = deltaMagnitude + pow(frameCount - frameCountCap, 1.4);
      float endX = px + delta.x * newLength;
      float endY = py + delta.y * newLength;
      if ((endX >= radius) && (endX < width - radius) &&
          (endY >= radius) && (endY < height - radius))
      {
        line(px, py, endX, endY);
      }
    }
    */
  }
  
  if (layer <= 1)
    return;
  
  for (int i = 0; i < childCount; i++)
  {
    color innerColor = getFillColor();
    float innerRadius = getRadius(layer - 1);
    
    float extraDistance = random(extraDistancePerLayerMin, extraDistancePerLayerMax) * layer;
    float distance = radius + innerRadius + extraDistance;
  
    //int cappedFrameCount = min(frameCount, frameCountCap);
  
    float angle = noise(layer * 100 + i, frameCount * 0.001 * speed, extraDistance) * PI * 2 * 10;
    float dx = cos(angle);
    float dy = sin(angle);
    
    float pangle = noise(layer * 100 + i, (frameCount - 1) * 0.001 * speed, extraDistance) * PI * 2 * 10;
    float pdx = cos(pangle);
    float pdy = sin(pangle);
    
    drawCircle(layer - 1,
               x + dx * distance, y + dy * distance,
               px + pdx * distance, py + pdy * distance,
               innerRadius, innerColor);
  }
}

float getRadius(int layer)
{
  return random(radiusPerLayerMin, radiusPerLayerMax) * layer;
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    setup();
  }
  else if (mouseButton == RIGHT)
  {
    paused = !paused;
  }
}

color getFillColor()
{
  //return color(random(255), 255, 255);
  return currentPalette.randomColor();
  //return color(random(255));
  
  /*
  color c = currentPalette.randomColor();
  float r = red(c);
  float g = green(c);
  float b = blue(c);
  float offset = 20;
  return color(max(0, min(255, r + random(-offset, offset))),
               max(0, min(255, g + random(-offset, offset))),
               max(0, min(255, b + random(-offset, offset))));
  */
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

class Palette
{
  ArrayList<Integer> colors = new ArrayList<Integer>();
  ArrayList<Float> widths = new ArrayList<Float>();
  float totalWidth = 0;
  
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
