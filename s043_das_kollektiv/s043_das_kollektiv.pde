/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.

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
boolean alternateColorSchemes = false;

int fieldSize = 48;
int fieldCount;
int border = 1;

int drawLength = 1400;
int markStepMin = 15;
int markStepMax = 60;

int targetDistanceMin = 10;
int targetDistanceMax = 30;
int minTargetStep = 5;
int maxTargetStep = Integer.MAX_VALUE;
float minTargetDistance = 0;
float maxTargetDistance = 60;
float minTotalLength = 100;
int eatenCount = 30;
int minEntityCount = 400;
int maxEntityCount = 800;

int visitorBorder = 2;
float visitorDiameterMin = 24;
float visitorDiameterMax = 36;
int minVisitorCount = 10;
int maxVisitorCount = 20;

Tile[][] tiles;
int tileGradientCounter;

ArrayList<Visitor> visitors = new ArrayList<Visitor>();
ArrayList<Entity> entities = new ArrayList<Entity>();

color visitorColor = color(0, 0, 255, 100);
color visitorEatenColor = color(255, 0, 0, 100);
color entityColor = color(255, 0, 0, 50);

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

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(true);
  }
  else if (mouseButton == RIGHT)
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
    ArrayList<Integer> colors = currentPalette.colors;
    chosenColors = new ArrayList<Integer>();
    chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
    chosenColors.add(colors.get((int)random(0, currentPalette.colors.size())));
    if (random(1) > 0.5)
      chosenColors = colors;
    
    if (alternateColorSchemes)
    {
      visitorColor = setAlphaPercent(chosenColors.get(0), 0.5);
      visitorEatenColor = setAlphaPercent(chosenColors.get(1), 0.5);
      entityColor = setAlphaPercent(chosenColors.get(1), 0.25);
    }
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
  
  float visitorRandom = 5;
  ArrayList<PVector> possibleVisitorPositions = new ArrayList<PVector>();
  for (int x = visitorBorder; x < fieldCount-visitorBorder; x++)
  {
    for (int y = visitorBorder; y < fieldCount-visitorBorder; y++)
    {
      if(tiles[x][y].solid)
        possibleVisitorPositions.add(new PVector((x+0.5) * fieldSize + random(-visitorRandom, visitorRandom),
                                                 (y+0.5) * fieldSize + random(-visitorRandom, visitorRandom)));
    }
  }
  
  Collections.shuffle(possibleVisitorPositions);
  
  visitors.clear();
  int visitorCount = (int)random(minVisitorCount, maxVisitorCount+1);
  for (int i = 0; i < visitorCount; i++)
  {
    visitors.add(new Visitor(possibleVisitorPositions.get(i)));
  }
  
  entities.clear();
  int entityCount = (int)random(minEntityCount, maxEntityCount+1);
  for (int i = 0; i < entityCount; i++)
  {
    entities.add(new Entity(startX, startY));
  }
  
  steps();
  finalDraw();
}

void steps()
{
  for (int i = 0; i < steps; i++)
  {
    for (Entity entity : entities)
    {
      entity.step();
    }
  }

  for (Entity entity : entities)
  {
    entity.takeTargetStep();
  }
}

void finalDraw()
{
  blendMode(BLEND);
  
  drawMap();
  
  blendMode(ADD);
  
  noStroke();
  noFill();
  
  for (Entity entity : entities)
  {
    entity.draw();
  }
  
  noFill();
  for (Visitor visitor : visitors)
  {
    visitor.draw();
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
  
  /*
  drawMap();
  
  for (Entity entity : entities)
  {
    entity.step();
  }
  */
      
  pause = true;
}

void drawMap()
{
  float maxOffset = 5;
  //float maxRotation = PI/2;
  
  noStroke();
  for (int x = 0; x < fieldCount; x++)
  {
    for (int y = 0; y < fieldCount; y++)
    {
      if (isSolid(x, y))
      {
        stroke(random(15, 25));
        //fill(random(5, 10));
        fill(random(0, 8));
      }
      else
      {
        //noStroke();
        //fill(0);
        continue;
        //fill(10 + (1-tiles[x][y].gradient/(float)tileGradientCounter)*245);
      }
      pushMatrix();
      //rotate(random(-maxRotation, maxRotation));
      /*
      rect(x * fieldSize + random(-maxOffset, maxOffset),
           y * fieldSize + random(-maxOffset, maxOffset),
           fieldSize + random(-maxOffset, maxOffset),
           fieldSize + random(-maxOffset, maxOffset));
      */
      beginShape();
      float x1 = x * fieldSize;
      float y1 = y * fieldSize;
      float x2 = x1 + fieldSize;
      float y2 = y1 + fieldSize;
      vertex(x1  + random(-maxOffset, maxOffset), y1 + random(-maxOffset, maxOffset));
      vertex(x2  + random(-maxOffset, maxOffset), y1 + random(-maxOffset, maxOffset));
      vertex(x2  + random(-maxOffset, maxOffset), y2 + random(-maxOffset, maxOffset));
      vertex(x1  + random(-maxOffset, maxOffset), y2 + random(-maxOffset, maxOffset));
      endShape(CLOSE);
      popMatrix();
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
  ArrayList<PVector> previousPositions = new ArrayList<PVector>();
  boolean dead;
  int nextMarkerCountdown;
  boolean hasEaten;
  Visitor target = null;
  float targetDistance = Float.MAX_VALUE;
  float totalLength = 0;
  
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
      //previousPositions.add(new PVector(position.x, position.y));
      direction = null;
      return;
    }
    
    //previousPositions.add(new PVector(position.x, position.y));
    direction = PVector.sub(target, position);
    direction.normalize();
  }
  
  public void step()
  {
    if (!isDead())
    {
      nextMarkerCountdown--;
      if (nextMarkerCountdown <= 0)
      {
        previousPositions.add(new PVector(position.x, position.y));
        nextMarkerCountdown = (int)random(markStepMin, markStepMin);
      }
      
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

      takeTargetStep();
    }
    
    /*
    strokeWeight(1);
    stroke(entityColor);
    point(position.x, position.y);
    */
  }
  
  void findClosestTarget()
  {
    target = null;
    targetDistance = Float.MAX_VALUE;
    for (Visitor visitor : visitors)
    {
      float distance = PVector.dist(position, visitor.position);
      if (distance < targetDistance)
      {
        target = visitor;
        targetDistance = distance;
      }
    }
  }
  
  void takeTargetStep()
  {
    if (isDead())
      return;
    
    findClosestTarget();
    
    if (!target.available())
      return;
      
    if ((targetDistance < minTargetDistance) || (targetDistance > maxTargetDistance))
      return;
    
    PVector deltaToTarget = PVector.sub(target.position, position);
    targetDistance = min(maxTargetStep, targetDistance - visitorDiameterMax/2)
                        - random(targetDistanceMin, targetDistanceMax);
    if (targetDistance < 0)
      targetDistance = minTargetStep;
      
    deltaToTarget.normalize();
    
    position.x += deltaToTarget.x * targetDistance;
    position.y += deltaToTarget.y * targetDistance;
    
    previousPositions.add(new PVector(position.x, position.y));
    
    calculateTotalLength();
    if (totalLength >= minTotalLength)
    {
      hasEaten = true;
      target.eat();
    }
    
    direction = null;
  }
  
  void calculateTotalLength()
  {
    totalLength = 0;
    PVector previous = null;
    for (PVector current : previousPositions)
    {
      if (previous != null)
      {
        totalLength += PVector.dist(current, previous);
      }
      previous = current;
    }
  }
  
  void draw()
  {
    if (!hasEaten)
      return;
    
    if (direction != null)
    {
      //previousPositions.add(new PVector(position.x, position.y));
      direction = null;
    }
    
    calculateTotalLength();

    if (totalLength < minTotalLength)
      return;

    noStroke();
    noFill();

    float startLength = max(totalLength - drawLength, 0);
    float lengthRange = totalLength - startLength;
    float previousLength = -startLength;
    PVector previous = null;
    for (PVector current : previousPositions)
    {
      if (previous != null)
      {
        float length = PVector.dist(current, previous);
        if (previousLength >= 0)
        {
          float fromPercent = pow(previousLength/lengthRange, 4);
          float toPercent = pow((previousLength+length)/lengthRange, 4);
          gradientLine(previous.x, previous.y, current.x, current.y, entityColor, fromPercent, toPercent);
        }
        previousLength += length;
      }
      previous = current;
    }
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

public class Visitor
{
  PVector position;
  int eatenCountLeft;
  
  public Visitor(PVector position)
  {
    this.position = position;
    eatenCountLeft = eatenCount;
  }
  
  public void eat()
  {
    eatenCountLeft--;
  }
  
  public boolean available()
  {
    return eatenCountLeft > 0;
  }
  
  public void draw()
  {
    float eatenPercent = 1 - (float)eatenCountLeft / eatenCount;
    float offset = 3;
    int visitorDiameter = (int)random(visitorDiameterMin, visitorDiameterMax+1);
    //for (int i = 1; i <= visitorDiameter; i++)

    strokeWeight(1);
    for (int i = visitorDiameter; i >= 1; i--)
    {
      //float percent = 1-((float)i/visitorRadius);
      float percent = random(0, 1);
      float eatenStrength = lerp(eatenPercent, 0, percent);
      //percent = max(eatenStrength, percent);
      stroke(setAlphaPercent(lerpColor(visitorColor, visitorEatenColor, eatenStrength), percent));
      //stroke(setAlphaPercent(visitorColor, percent));
      ellipse(position.x + random(-offset, offset), position.y + random(-offset, offset), i, i);
    }

    /*
    for (int i = (int)(visitorDiameter * eatenPercent); i >= 1; i--)
    {
      //float percent = 1-((float)i/visitorRadius);
      float percent = random(0, 1);
      //stroke(setAlphaPercent(lerpColor(visitorColor, visitorEatenColor, eatenPercent * pow(percent, 1)), percent));
      stroke(setAlphaPercent(visitorEatenColor, percent));
      ellipse(position.x + random(-offset, offset), position.y + random(-offset, offset), i, i);
    }
    */
  }  
}

color setAlphaPercent(color original, float percent)
{
  if (int(alpha(original) * percent) == 0)
    return color(0,0,0,0);
    
  return color(red(original), green(original), blue(original), alpha(original) * percent);
}

void gradientLine(float x1, float y1, float x2, float y2, color c, float alphaFromPercent, float alphaToPercent)
{
  float r = red(c);
  float g = green(c);
  float b = blue(c);
  float a = alpha(c);
  
  float deltaX = x2-x1;
  float deltaY = y2-y1;
  float tStep = 1.0/dist(x1, y1, x2, y2);
  for (float t = 0.0; t < 1.0; t += tStep) {
    //fill(lerpColor(a, b, t));
    fill(r, g, b, a * lerp(alphaFromPercent, alphaToPercent, t));
    ellipse(x1+t*deltaX,  y1+t*deltaY, 2, 2);
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