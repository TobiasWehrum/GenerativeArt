/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

String paletteFileName = "top100";

float scale = 1;
int steps = 200;
boolean pause = false;
boolean ignoreWidth = true;

ArrayList<Palette> palettes = new ArrayList<Palette>();
Palette currentPalette;

Planet centerPlanet;

void setup()
{
  int originalWidth = 768;
  int originalHeight = 768;
  int desiredWidth = 768;
  int desiredHeight = 768;
  size(768, 768, P2D);
  //fullScreen(P2D);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
  
  //blendMode(ADD);

  //scaledSize(768, 768, displayWidth, displayHeight);

  loadPalettes();

  reset(false);
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(false);
  }
}

void reset(boolean keepHue)
{
  if (!keepHue)
  {
    int paletteIndex = (int)random(palettes.size());
    currentPalette = palettes.get(paletteIndex);
  }
  
  background(0);
  //stroke(140, 1);
  stroke(255, 5);
  //stroke(255);
  
  pause = false;
  
  createGalaxy();
}

void draw()
{
  if (pause)
    return;
  
  background(0);
  
  //randomSeed(0);
  
  centerPlanet.drawOrbit(width/2, height/2, 1);
  centerPlanet.drawPlanet(width/2, height/2);
  //for (int i = 0; i < 10; i++)
  //  makeStar(random(0.2, 0.5));
    
  pause = true;
}

float planetRadiusMaxByHeight = 1f/10;
float planetRadiusMinByHeight = planetRadiusMaxByHeight / 3;
float planetRadiusMin;
float planetRadiusMax;

void createGalaxy()
{
  planetRadiusMin = height * planetRadiusMinByHeight;
  planetRadiusMax = height * planetRadiusMaxByHeight;
  
  centerPlanet = createGalaxy(0, height/2, 1);
}

Planet createGalaxy(float distance, float spaceLeft, int depth)
{
  float currentMin = planetRadiusMin / depth;
  float currentMax = planetRadiusMax / depth;
  //float radius = random(min(currentMin, spaceLeft/2), min(currentMax, spaceLeft/2));
  float radius = min(currentMax, spaceLeft/2);
  
  if (distance > 0)
  {
    distance += radius / 2;
    spaceLeft -= radius * 2;
  }
  
  Planet planet = new Planet(distance, radius);
  
  float startDistance = radius;
  
  while (spaceLeft > currentMax)
  {
    float reserveSpace = random(currentMin*2, spaceLeft/2);
    if (((depth == 1) && (random(1) > 0.9)) || (depth > 1))
    {
      reserveSpace = random(currentMin*2, currentMax*2);
    }
    reserveSpace = min(reserveSpace, spaceLeft);
    //if (reserveSpace > planetRadiusMax
    planet.subPlanets.add(createGalaxy(startDistance + reserveSpace / 2, reserveSpace - currentMin, depth+1));
    spaceLeft -= reserveSpace;
    startDistance += reserveSpace;
  }
  
  return planet;
}


void drawStar(float x, float y, float maxRadius)
{
  int paletteIndex = (int)random(palettes.size());
  currentPalette = palettes.get(paletteIndex);
  
  strokeWeight(1);
  int count = (int)random(5, 15);
  float angleFrom = random(-PI*2, PI*2);
  /*
  int x = width/2;
  int y = height/2;
  x = (int)random(0, width);
  y = (int)random(0, height);
  */
  ArrayList<Integer> colors = currentPalette.colors;
  ArrayList<Integer> chosenColors = new ArrayList<Integer>();
  chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
  chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
  if (random(1) > 0.5)
    chosenColors = colors;
  for (int i = 0; i < count; i++)
  {
    stroke(chosenColors.get((int)random(0, chosenColors.size())), random(50 * 5, 100 * 20) / maxRadius);
    //angleFrom = random(-PI/2, PI/2);
    
    //float angleTo = angleFrom + random(-PI/2, PI/2);
    float angleTo = angleFrom + random(PI/4, PI);
    float radius = random(maxRadius / 3, maxRadius);
    int stepCount = (int)(abs(angleTo-angleFrom)*random(50, 200));
    float innerRadius = 0;//random(0, 1);
    if (random(1) > 0.5)
      innerRadius = random(0, 1);
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
  }
}

class Planet
{
  float angle;
  float distance;
  float radius;
  ArrayList<Planet> subPlanets;
  float speed;
  
  Planet(float distance, float radius)
  {
    this.distance = distance;
    this.radius = radius;
    angle = random(0, PI*2);
    subPlanets = new ArrayList<Planet>();
    
    speed += random(0.00001, 0.00005) * distance;
  }
  
  void drawOrbit(float centerX, float centerY, int depth)
  {
    angle += speed;
    
    if (subPlanets.size() == 0)
      return;
    
    centerX += cos(angle) * distance;
    centerY += sin(angle) * distance;
    
    noFill();
    //strokeWeight(5f/depth);
    //stroke(120);
    strokeWeight(2);
    stroke(120/depth);
    
    for (Planet planet : subPlanets)
    {
      ellipse(centerX, centerY, planet.distance * 2, planet.distance * 2);
    }
    
    for (Planet planet : subPlanets)
    {
      planet.drawOrbit(centerX, centerY, depth+1);
    }
  }
  
  void drawPlanet(float centerX, float centerY)
  {
    if (distance > 0)
    {
      centerX += cos(angle) * distance;
      centerY += sin(angle) * distance;
    }
    
    drawStar(centerX, centerY, radius);
    
    for (Planet planet : subPlanets)
    {
      planet.drawPlanet(centerX, centerY);
    }
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