/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- +/- to change speed.
- 1 to 9: Set scale.
- i: Switch between drawing or instant.
- s: Switch between straight or zig-zag.
*/

// Palettes from:
// - http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1&numResults=100
// - http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1&numResults=100&keywords=mondrian
// - http://www.colourlovers.com/api/palettes/top?showPaletteWidths=1&numResults=10&keywords=mondrian

String paletteFileName = "top100";
//String paletteFileName = "mondrian10";
int speed = 1;
int crawlerDistance = 10;
int crawlerDistanceAddVariance = 20;
int scale = 4;
color backgroundColor;
color lineColor;
float addedWhiteMin = 0.5;
float addedWhiteMax = 2;
float switchToAltChance = 0.025;

boolean straight = true; 
boolean instant = false;

ArrayList<Crawler> crawlers = new ArrayList<Crawler>();
int nextCrawlerRelease;

ArrayList<Palette> palettes;
Palette currentPalette;

void setup()
{
  size(500, 500);
  //colorMode(HSB, 255);

  if (palettes == null)
  {
    palettes = new ArrayList<Palette>();
    loadPalettes();
  }
  
  int paletteIndex = (int)random(palettes.size());
  currentPalette = palettes.get(paletteIndex);
  
  crawlers.clear();
  
  int dx = 0;
  int dy = 0;
  int x = 0;
  int y = 0;
  int direction = (random(1) > 0.5) ? -1 : 1;
  if (random(1) >= 0.5)
  {
    dx = direction;
    x = (direction == 1) ? -scale : width;
    y = (int) random(height + 1 - scale);
  }
  else
  {
    dy = direction;
    x = (int) random(width + 1 - scale);
    y = (direction == 1) ? -scale : height;
  }
  
  crawlers.add(new Crawler(x, y, dx, dy));
  nextCrawlerRelease = crawlerDistance + round(random(crawlerDistanceAddVariance));
  
  lineColor = color(0, 0, 0);
  backgroundColor = color(255, 255, 255);
  background(backgroundColor);
  
  if (instant)
  {
    loadPixels();
    while (crawlers.size() > 0)
    {
      step();
    }
    updatePixels();
  }
}

void draw()
{
  if (crawlers.size() <= 0)
    return;
    
  loadPixels();
  for (int i = 0; (i < speed); i++)
  {
    step();
  }
  updatePixels();
}

void step()
{
  if (crawlers.size() <= 0)
    return;

  for (int i = 0; i < crawlers.size(); i++)
  {
    Crawler crawler = crawlers.get(i);
    boolean isDone = crawler.update();
    crawler.draw();
    if (isDone)
    {
      crawler.draw();
      crawlers.remove(i);
      floodFill(crawler);
      i--;
    }
    else
    {
      crawler.draw();
    }
  }
  
  if (crawlers.size() <= 0)
    return;
  
  nextCrawlerRelease--;
  if (nextCrawlerRelease == 0)
  {
    nextCrawlerRelease = crawlerDistance + round(random(crawlerDistanceAddVariance));
    releaseNextCrawler();
  }
}

void releaseNextCrawler()
{
  int i = (int)random(crawlers.size());
  Crawler parent = crawlers.get(i);
  
  int dx = 0;
  int dy = 0;
  int direction = (random(1) > 0.5) ? -1 : 1;
  if (parent.dx != 0)
  {
    dy = direction;
  }
  else
  {
    dx = direction;
  }
  
  Crawler crawler = new Crawler(parent.x, parent.y, dx, dy);
  boolean isDone = crawler.update();
  crawler.draw();
  if (isDone)
  {
    floodFill(crawler);
  }
  else
  {
    crawlers.add(crawler);
  }
}

void mouseWheel(MouseEvent event) {
  speed = max(speed - event.getCount(), 1);
}

void keyPressed()
{
  if (key == '+')
  {
    speed++;
  }
  else if (key == '-')
  {
    if (speed > 1)
      speed--;
  }
  
  if (key == 'i')
  {
    instant = !instant;
    setup();
  }
  
  if (key == 's')
  {
    straight = !straight;
    setup();
  }
  
  if ((key >= '1') && (key <= '9'))
  {
    scale = Integer.parseInt(key + "");
    setup();
  }
  
  if (key == ' ')
  {
    setup();
  }
}

void mouseClicked()
{
  setup();
}

void floodFill(Crawler crawler)
{
  int offsetX = (crawler.dx == 0) ? 1 : 0;
  int offsetY = (crawler.dy == 0) ? 1 : 0;
  int x = crawler.x - crawler.dx * scale;
  int y = crawler.y - crawler.dy * scale;
  floodFill(x + offsetX * scale, y + offsetY * scale, getFillColor());
  floodFill(x - offsetX, y - offsetY, getFillColor());
}

void floodFill(int startX, int startY, color fillColor)
{
  updatePixels();
  
  ArrayList<PVector> positionsToTest = new ArrayList<PVector>();
  positionsToTest.add(new PVector(startX, startY));
  while (positionsToTest.size() > 0)
  {
    PVector position = positionsToTest.get(0);
    positionsToTest.remove(0);
    int x = (int) position.x;
    int y = (int) position.y;
    
    if ((x < 0) || (y < 0) || (x >= width) || (y >= height))
      continue;
    
    int index = x + y * width;
    color currentColor = pixels[index];
    if (currentColor == lineColor)
    {
      for (Crawler crawler : crawlers)
      {
        if (crawler.sitsOn(x, y))
        {
          loadPixels();
          return;
        }
      }
    }
    else if (currentColor != fillColor)
    {
      pixels[index] = fillColor;
      positionsToTest.add(new PVector(x - 1, y));
      positionsToTest.add(new PVector(x + 1, y));
      positionsToTest.add(new PVector(x, y - 1));
      positionsToTest.add(new PVector(x, y + 1));
    }
  }
}

color getFillColor()
{
  //return color(random(255), 255, 255);
  return currentPalette.randomColor();
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
    
    float addedWhite = random(addedWhiteMin, addedWhiteMax);
    if (addedWhite > 0)
    {
      palette.addColor(color(255, 255, 255), addedWhite);
    }
    
    palettes.add(palette);
  } 
}

class Crawler
{
  int x;
  int y;
  int dx;
  int dy;
  int altDX;
  int altDY;
  
  Crawler(int x, int y, int dx, int dy)
  {
    this.x = x;
    this.y = y;
    this.dx = dx;
    this.dy = dy;
    
    altDX = dy;
    altDY = dx;
    if (random(1) > 0.5)
    {
      altDX *= -1;
      altDY *= -1;
    }
  }
  
  boolean outOfRange()
  {
    return (x < 0) || (y < 0) || (x >= width) || (y >= height);
  }
  
  int getCurrentIndex()
  {
    return x + y * width;
  }
  
  boolean sitsOn(int testX, int testY)
  {
    return (x <= testX) && (testX < x + scale) &&
           (y <= testY) && (testY < y + scale);
  }
  
  boolean update()
  {
    if (!straight)
    {
      if (random(1) < switchToAltChance)
      {
        int tDX = dx;
        int tDY = dy;
        dx = altDX;
        dy = altDY;
        altDX = tDX;
        altDY = tDY;
      }
    }
    
    x += dx * scale;
    y += dy * scale;
    
    return outOfRange() || (pixels[getCurrentIndex()] != backgroundColor);
  }
  
  void draw()
  {
    int endX = min(x + scale, width);
    int endY = min(y + scale, height);
    for (int drawX = max(x, 0); drawX < endX; drawX++)
    {
      for (int drawY = max(y, 0); drawY < endY; drawY++)
      {
        pixels[drawX + drawY * width] = lineColor;
      }
    }
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
