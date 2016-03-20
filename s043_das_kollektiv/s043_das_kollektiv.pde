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

import java.util.*;

String paletteFileName = "selected2";

int fieldSize = 48;
int fieldCount;
int border = 1;

Tile[][] tiles;
int tileGradientCounter;

ArrayList<Entity> entities = new ArrayList<Entity>();

color visitorColor = color(0, 0, 255);
color entityColor = color(255, 0, 0);

float scale = 1;
int steps = 2000;
boolean pause = false;
boolean ignoreWidth = true;
int frameNumber;

ArrayList<Palette> palettes = new ArrayList<Palette>();
Palette currentPalette;

ArrayList<Integer> chosenColors;

ArrayList<Coordinates> directions = new ArrayList<Coordinates>();

void setup()
{
  int originalWidth = 768;
  int originalHeight = 768;
  int desiredWidth = 768;
  int desiredHeight = 768;
  size(768, 768, P2D);
  //fullScreen(P2D);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
  
  directions.add(new Coordinates(1, 0));
  directions.add(new Coordinates(-1, 0));
  directions.add(new Coordinates(0, 1));
  directions.add(new Coordinates(0, -1));
  
  fieldCount = height/fieldSize;
  
  //blendMode(ADD);

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
  
  noiseSeed((int)random(0, 100000000));
  
  background(0);
  //stroke(140, 1);
  //stroke(255, 5);
  //stroke(255);
  strokeWeight(1);
  
  pause = false;
  frameNumber = 0;
  
  tiles = new Tile[fieldCount][fieldCount];
  for (int x = 0; x < fieldCount; x++)
  {
    for (int y = 0; y < fieldCount; y++)
    {
      tiles[x][y] = new Tile();
    }
  }
  
  int startX = (int)random(border, fieldCount-border);
  int startY = (int)random(border, fieldCount-border);
  startX = fieldCount / 2;
  startY = fieldCount / 2;
  burrow(startX, startY, 0, 1);
  
  Queue<Coordinates> queue = new LinkedList<Coordinates>();
  queue.add(new Coordinates(startX, startY));
  queue.add(null);
  tileGradientCounter = 0;
  while (!queue.isEmpty())
  {
    Coordinates c = queue.remove();
    if (c == null)
    {
      tileGradientCounter++;
      if (!queue.isEmpty())
        queue.add(null);
        
      continue;
    }
    
    if (tiles[c.x][c.y].gradient != -1)
      continue;
    
    tiles[c.x][c.y].gradient = tileGradientCounter;
    
    for (Coordinates direction : directions)
    {
      int x = c.x + direction.x;
      int y = c.y + direction.y;
      if (isValid(x, y) && !isSolid(x, y))
      {
        queue.add(new Coordinates(x, y));
      }
    }
  }
  
  entities.clear();
  int entityCount = 100;
  for (int i = 0; i < entityCount; i++)
  {
    entities.add(new Entity(startX, startY));
  }
}

void draw()
{
  if (pause)
    return;
  
  frameNumber++;
  
  //background(0);
  /*
  noStroke();
  fill(0, 10);
  rect(0, 0, width, height);
  noFill();
  */
  
  drawMap();
  
  for (Entity entity : entities)
  {
    entity.step();
  }
      
  //pause = true;
}

void drawMap()
{
  noStroke();
  for (int x = 0; x < fieldCount; x++)
  {
    for (int y = 0; y < fieldCount; y++)
    {
      if (isSolid(x, y))
      {
        fill(5);
      }
      else
      {
        fill(0, 10);
        //fill(10 + (1-tiles[x][y].gradient/(float)tileGradientCounter)*245);
      }
      rect(x * fieldSize, y * fieldSize, fieldSize, fieldSize);
    }
  }
}

boolean burrow(int x, int y, int counter, float chance)
{
  if (!isValid(x, y))
    return false;
  
  if (!isSolid(x, y))
    return false;
    
  int solidCounter = 0;
  if (isSolid(x-1, y)) solidCounter++;
  if (isSolid(x+1, y)) solidCounter++;
  if (isSolid(x, y-1)) solidCounter++;
  if (isSolid(x, y+1)) solidCounter++;
  if (isSolid(x-1, y-1)) solidCounter++;
  if (isSolid(x-1, y+1)) solidCounter++;
  if (isSolid(x+1, y-1)) solidCounter++;
  if (isSolid(x+1, y+1)) solidCounter++;
  
  int freeCounter = 8 - solidCounter;
  
  if (freeCounter >= 4)
    return false;
    
  tiles[x][y].solid = false;
  
  float nextChance = chance * 0.9;
  int nextCounter = counter + 1;
  
  Collections.shuffle(directions);
  
  for (Coordinates direction : directions)
  {
    boolean burrowed = burrow(x+direction.x, y+direction.y, nextCounter, nextChance);
    if (burrowed && (random(1) > chance)) break;
  }
  
  return true;
}

boolean isValid(int x, int y)
{
  return (x >= border) && (y >= border) && (x < fieldCount-border) && (y < fieldCount-border);
}

boolean isSolid(int x, int y)
{
  return !isValid(x, y) || tiles[x][y].solid;
}

class Tile
{
  //ArrayList<PVector> directions = new ArrayList<PVector>();
  int gradient = -1;
  boolean solid = true;
  
  public Tile()
  {
  }
}

class Coordinates
{
  int x;
  int y;
  
  public Coordinates()
  {
  }
  
  public Coordinates(int x, int y)
  {
    this.x = x;
    this.y = y;
  }
}

class Entity
{
  PVector position;
  PVector direction;
  boolean dead;
  
  public Entity(int tileX, int tileY)
  {
    position = new PVector(tileX*fieldSize + random(0, fieldSize), tileY*fieldSize + random(0, fieldSize));
    chooseDirection(currentCoordinates());
  }
  
  public void chooseDirection(Coordinates from)
  {
    PVector target = findHigherGround(from);
    if (target == null)
    {
      direction = null;
      return;
    }
    
    direction = PVector.sub(target, position);
    direction.normalize();
  }
  
  public void step()
  {
    if (!isDead())
    {
      Coordinates previous = currentCoordinates();
      position.add(direction);
      
      Coordinates newCoordinates = currentCoordinates();
      if ((previous.x != newCoordinates.x) || (previous.y != newCoordinates.y))
      {
        if (isSolid(newCoordinates.x, newCoordinates.y))
        {
          position.sub(direction);
          chooseDirection(previous);
          
          if (isDead())
            return;
            
          position.add(direction);
        }
        else
        {
          PVector oldDir = direction;
          chooseDirection(newCoordinates);
          if (isDead())
            direction = oldDir;
        }
      }
    }
    
    strokeWeight(1);
    stroke(entityColor);
    point(position.x, position.y);
  }
  
  public Coordinates currentCoordinates()
  {
    return new Coordinates((int)(position.x / fieldSize), (int)(position.y / fieldSize));
  }
  
  public boolean isDead()
  {
    return direction == null;
  }
}

PVector findHigherGround(Coordinates c)
{
  Tile currentTile = tiles[c.x][c.y];
  Collections.shuffle(directions);
  for (Coordinates direction : directions)
  {
    int x = c.x + direction.x;
    int y = c.y + direction.y;
    if (isValid(x, y) && !isSolid(x, y) && (tiles[x][y].gradient > currentTile.gradient))
    {
      return new PVector(x*fieldSize+random(1, fieldSize-1), y*fieldSize+random(1, fieldSize-1));
    }
  }
  
  return null;
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