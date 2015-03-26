/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to lock/unlock a tile.
- Mouse wheel to change font.
*/

import geomerative.*;

ArrayList<String> fonts = new ArrayList<String>();
String font;
int size = 72;

float scale = 1;

int sectorSize;
int countX;
int countY;
float baseX;
float baseY;

ArrayList<Character> charsNoseUnrotated = new ArrayList<Character>();
ArrayList<Character> charsNoseRotated = new ArrayList<Character>();
ArrayList<Character> charsNoseAny = new ArrayList<Character>();

ArrayList<Character> charsEyesCompleteRotated = new ArrayList<Character>();
ArrayList<Character> charsEyesSingle = new ArrayList<Character>();

ArrayList<Character> charsMouthUnrotated = new ArrayList<Character>();
ArrayList<Character> charsMouthRotated = new ArrayList<Character>();
ArrayList<Character> charsMouthAny = new ArrayList<Character>();

ArrayList<Character> charsSideUnrotated = new ArrayList<Character>();
ArrayList<Character> charsSideRotated = new ArrayList<Character>();
ArrayList<Character> charsSideAny = new ArrayList<Character>();

ArrayList<Character> charsTopUnrotated = new ArrayList<Character>();
ArrayList<Character> charsTopRotated = new ArrayList<Character>();
ArrayList<Character> charsTopAny = new ArrayList<Character>();

int[][] sectorSeed;
boolean[][] sectorLocked;
int[][] sectorFontIndex;
int lockedSectors;
int fontIndex;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  int side = 1000;
  scaledSize(500, 500, side, side);
  colorMode(HSB, 255);
  smooth();
  
  fonts.add("FreeSans.ttf");
  fonts.add("WereWolf.ttf");
  
  //addChars(charsHorizontalSymmetrical, "AHMUVWXY_movwx");
  //addChars(charsVertical, "!$&()/0123456789:;?BCDEFGIJKLNPRSTZ[\\]abcdefghijklnpqrstuyz{|}~");
  //addChars(charsRoundBig, "#%@OQ");
  //addChars(charsRound, "\"'*+,-.<>=^´`");
  
  addChars(charsNoseUnrotated, "AHMUVWXYmovwy!$&/0123456789?BCDEFGIJKLNPRSTZ[\\]abcdefghijklnpqrstuxz{|}~");
  addChars(charsNoseRotated, "_~");
  addChars(charsNoseAny, "#%@OQ\"'*+,-.<>=^´`°");
  
  addChars(charsEyesCompleteRotated, ":;8B");
  addChars(charsEyesSingle, "#%@OQ\"'*+,-.<>=^´`x");
  
  addChars(charsMouthUnrotated, "AHMUVWXY_movwx~");
  addChars(charsMouthRotated, "!$&()/0123456789?BCDEFGIJKLNPRSTZ[\\]abcdefghijklnpqrstuyz{|}");
  addChars(charsMouthAny, "#%@OQx");
  
  addChars(charsMouthUnrotated, "AHMUVWXY_movwx~");
  addChars(charsMouthRotated, "!$&()/0123456789?BCDEFGIJKLNPRSTZ[\\]abcdefghijklnpqrstuyz{|}");
  addChars(charsMouthAny, "#%@OQx");
  
  addChars(charsSideUnrotated, "");
  addChars(charsSideRotated, "");
  addChars(charsSideAny, "#%@OQ\"'*+,-.<>=^´`x");
  
  addChars(charsTopUnrotated, "AHMUVWXY_movwx~");
  addChars(charsTopRotated, "!$&()/0123456789?BCDEFGIJKLNPRSTZ[\\]abcdefghijklnpqrstuyz{|}");
  addChars(charsTopAny, "");
  
  RG.init(this);
  
  sectorSize = height / 3;
  countX = width / sectorSize;
  countY = height / sectorSize;
  baseX = (width - (countX * sectorSize)) / 2;
  baseY = (height - (countY * sectorSize)) / 2;
  
  sectorSeed = new int[countX][countY];
  sectorLocked = new boolean[countX][countY];
  sectorFontIndex = new int[countX][countY];

  font = fonts.get(0);

  refresh();
  //debugDraw();
}

void refresh()
{
  drawImage(false, true);
}

void debugDraw()
{
  background(0);
  drawCharacter('B', width / 2, height / 2, 0, 0.5, 0, 0, 0, false, false, false);
  stroke(255);
  line(width / 2, 0, width / 2, height);
  line(0, height / 2, width, height / 2);
}

void drawImage(boolean drawLocked, boolean randomize)
{
  font = fonts.get(fontIndex);
  
  int index = 0;
  
  for (int x = 0; x < countX; x++)
  {
    for (int y = 0; y < countY; y++)
    {
      if (sectorLocked[x][y] && !drawLocked)
        continue;
      
      if (!sectorLocked[x][y] && randomize)
      {
        sectorSeed[x][y] = (int) (random(100000) + frameCount + x + y);
        //sectorFontIndex[x][y] = (int) random(fonts.size());
      }
      
      drawSector(x, y);
    }
  }
}

void drawSector(int x, int y)
{
  randomSeed(sectorSeed[x][y]);
  //font = fonts.get(sectorFontIndex[x][y]);
  
  float brightnessBackground = random(0, 50);
  float brightnessEmoticon = 255;
  if (random(1) < 0.5)
  {
    brightnessBackground = 255 - brightnessBackground;
    brightnessEmoticon = 255 - brightnessEmoticon;
  }
  
  noStroke();
  fill(0, 0, brightnessBackground);
  //fill(0, 0, ((index % 2) == 0) ? brightnessBackgroundA : brightnessBackgroundB);
  rect(baseX + x * sectorSize, baseY + y * sectorSize, sectorSize, sectorSize);
  
  fill(0, 0, brightnessEmoticon);
  //fill(0, 0, ((index % 2) == 0) ? brightnessEmoticonA : brightnessEmoticonB);
  drawEmoticon(baseX + (x + 0.5) * sectorSize, baseY + (y + 0.5) * sectorSize, scale * 1.5 / countY);
  
  if ((lockedSectors > 0) && !sectorLocked[x][y])
  {
    noFill();
    stroke(255 - brightnessBackground);
    strokeWeight(4);
    float lockBorder = 30 * scale;
    rect(baseX + x * sectorSize + lockBorder, baseY + y * sectorSize + lockBorder,
         sectorSize - lockBorder * 2, sectorSize - lockBorder * 2);
         
    strokeWeight(1);
  }
}

void drawEmoticon(float x, float y, float emoticonScale)
{
  pushMatrix();
  noStroke();
  
  int oldSize = size;
  
  size = (int)(size * emoticonScale);
  
  translate(x, y);
  
  Bounds noseBounds = drawNose(emoticonScale);
  Bounds eyeBounds = drawEyes(noseBounds.yMin, emoticonScale);
  Bounds mouthBounds = drawMouth(noseBounds.yMax, emoticonScale);
  drawTop(eyeBounds.yMin, emoticonScale);
  drawSides(noseBounds.xCenter, noseBounds.yCenter, emoticonScale);
  
  size = oldSize;

  popMatrix();
}

Bounds drawNose(float emoticonScale)
{
  if (random(1) < 0.1)
    return new Bounds();
  
  MultiListElement element = random(charsNoseUnrotated, charsNoseRotated, charsNoseAny);
  float angle = 0;
  if (element.listIndex == 1)
  {
    angle = PI / 2;
  }
  else if (element.listIndex == 2)
  {
    angle = random(0, TWO_PI);
  }
  
  if (random(1) < 0.5)
  {
    angle += PI;
  }
  
  float setHeight = random(20, 30) * emoticonScale;
  return drawCharacter(element.c, 0, 0, 0.5, 0.5, angle, 0, setHeight, true, randomBool(0.2), randomBool(0.2));
}

Bounds drawEyes(float maxLineY, float emoticonScale)
{
  maxLineY -= random(0, 10) * emoticonScale;
  
  if (random(1) < 0.5)
  {
    return drawEyesComplete(maxLineY);
  }
  else
  {
    return drawEyesSingle(maxLineY, emoticonScale);
  }
}

Bounds drawEyesComplete(float maxLineY)
{
  return drawCharacter(random(charsEyesCompleteRotated), 0, maxLineY,  0.5, 1, PI / 2, 0, 0, false,
                       randomBool(0.2), randomBool(0.2));
}

Bounds drawEyesSingle(float maxLineY, float emoticonScale)
{
  char charA = random(charsEyesSingle);
  char charB = (random(1) < 0.5) ? charA : random(charsEyesSingle);

  float mirrorChance = 0.2;

  boolean mirrorXA = randomBool(mirrorChance);
  boolean mirrorXB = randomBool(0.95) ? mirrorXA : randomBool(mirrorChance);
  
  boolean mirrorYA = randomBool(mirrorChance);
  boolean mirrorYB = randomBool(0.95) ? mirrorYA : randomBool(mirrorChance);
  
  float rotationA = random(0, TWO_PI);
  float rotationB = 0;
  if (randomBool(0.95))
  {
    if (randomBool(0.5))
    {
      rotationB = rotationA; 
    }
    else
    {
      rotationB = -rotationA;
      if (randomBool(0.9))
      {
        mirrorXB = !mirrorXA;
      }
    }
  }
  else
  {
    rotationB = random(0, TWO_PI);
  }
  
  float distMin = 10 * emoticonScale;
  float distMay = 50 * emoticonScale;
  
  float distanceFromCenterA = random(distMin, distMay);
  float distanceFromCenterB = randomBool(0.95) ? distanceFromCenterA : random(distMin, distMay);
  
  float eyeHeightMin = 10 * emoticonScale;
  float eyeHeightMay = 30 * emoticonScale;
  
  float eyeHeightA = random(eyeHeightMin, eyeHeightMay); 
  float eyeHeightB = randomBool(0.95) ? eyeHeightA : random(eyeHeightMin, eyeHeightMay);

  Bounds boundsA = drawCharacter(charA, -distanceFromCenterA, maxLineY, 0.5, 1, rotationA, 0, eyeHeightA, true,
                                 mirrorXA, mirrorYA);
  Bounds boundsB = drawCharacter(charB, distanceFromCenterB, maxLineY, 0.5, 1, rotationB, 0, eyeHeightB, true,
                                 mirrorXB, mirrorYB);
  return new Bounds(boundsA, boundsB);
}

Bounds drawMouth(float minLineY, float emoticonScale)
{
  minLineY += random(5, 20) * emoticonScale;
  
  MultiListElement element = random(charsMouthUnrotated, charsMouthRotated, charsMouthAny);
  float angle = 0;
  if (element.listIndex == 1)
  {
    angle = PI / 2;
  }
  else if (element.listIndex == 2)
  {
    angle = random(0, TWO_PI);
  }
  
  if (random(1) < 0.5)
  {
    angle += PI;
  }
  
  //float setHeight = random(20, 50) * emoticonScale;
  return drawCharacter(element.c, 0, minLineY, 0.5, 0, angle, 0, 0, true, randomBool(0.2), randomBool(0.2));
}

Bounds drawTop(float maxLineY, float emoticonScale)
{
  if (randomBool(0.7))
    return new Bounds(0, maxLineY);
  
  maxLineY -= random(5, 20) * emoticonScale;
  
  MultiListElement element = random(charsTopUnrotated, charsTopRotated, charsTopAny);
  float angle = 0;
  if (element.listIndex == 1)
  {
    angle = PI / 2;
  }
  else if (element.listIndex == 2)
  {
    angle = random(0, TWO_PI);
  }
  
  if (random(1) < 0.5)
  {
    angle += PI;
  }
  
  float setWidth = 0;
  float setHeight = 0;
  if (randomBool(0.5))
  {
    setWidth = random(20, 110) * emoticonScale;
  }
  else
  {
    setHeight = random(20, 70) * emoticonScale;
  }
  
  float x = 0;
  float y = maxLineY;
  float ax = 0.5;
  float ay = 1;
  
  RGeomElem character = createCharacter(element.c, x, y, ax, ay, angle, setWidth, setHeight, true,
                                        randomBool(0.2), randomBool(0.2));
                                        
  return drawWithMaxScale(character, x, y, ax, ay, 110 * emoticonScale, 70 * emoticonScale, 0.5);
}

void drawSides(float centerX, float centerY, float emoticonScale)
{
  if (randomBool(0.7))
    return;
    
  MultiListElement element = random(charsSideUnrotated, charsSideRotated, charsSideAny);
  float angle = 0;
  if (element.listIndex == 1)
  {
    angle = PI / 2;
  }
  else if (element.listIndex == 2)
  {
    angle = random(0, TWO_PI);
  }
  
  if (random(1) < 0.5)
  {
    angle += PI;
  }
  
  float setWidth = 0;
  float setHeight = 0;
  if (randomBool(0.5))
  {
    setWidth = random(20, 110) * emoticonScale;
  }
  else
  {
    setHeight = random(20, 70) * emoticonScale;
  }
  
  float x = centerX;
  float y = centerY;
  float distanceFromCenter = random(20, 50) * emoticonScale;
  
  boolean mirrorX = randomBool(0.3);
  boolean mirrorY = randomBool(0.3);
  
  drawCharacter(element.c, -distanceFromCenter, y, 1, 0.5, angle, 0, 0, true, !mirrorX, mirrorY);
  drawCharacter(element.c, distanceFromCenter, y, 0, 0.5, -angle, 0, 0, true, mirrorX, mirrorY);
}

Bounds drawWithMaxScale(RGeomElem character, float x, float y, float anchorX, float anchorY, float maxWidth, float maxHeight,
                        float downScalingFactor)
{
  if (character == null)
    return new Bounds();
    
  while ((character.getWidth() > maxWidth) || (character.getHeight() > maxHeight))
  {
    character.scale(downScalingFactor);
  }
  
  RPoint center = character.getCenter();
  float offsetX = - character.getWidth() * (anchorX - 0.5);
  float offsetY = - character.getHeight() * (anchorY - 0.5);
  character.translate(x - center.x + offsetX, y - center.y + offsetY);
  
  character.draw();
  
  return new Bounds(character);
}

Bounds drawCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation, float setWidth,
                     float setHeight, boolean anchorFinalBox, boolean mirrorX, boolean mirrorY)
{
  RGeomElem character = createCharacter(c, x, y, anchorX, anchorY, rotation, setWidth, setHeight, anchorFinalBox,
                                        mirrorX, mirrorY);
                                        
  if (character == null)
    return new Bounds();

  character.draw();
  return new Bounds(character);
}

RGeomElem createCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation, float setWidth,
                          float setHeight, boolean anchorFinalBox, boolean mirrorX, boolean mirrorY)
{
  RShape group = RG.getText(c + "", font, size, LEFT);
  if ((group == null) || (group.children == null) || (group.children.length == 0))
  {
    return null;
  }
  RGeomElem character = group.children[0];
  
  character.scale((mirrorX ? -1 : 1), (mirrorY ? -1 : 1));
  
  float offsetX = 0;
  float offsetY = 0;
  float characterWidth = character.getWidth();
  float characterHeight = character.getHeight();
  
  if (!anchorFinalBox)
  {
    if (setHeight > 0)
    {
      float scale = setHeight / characterHeight;
      character.scale(scale);
      characterWidth *= scale;
      characterHeight *= scale;
    }
    else if (setWidth > 0)
    {
      float scale = setWidth / characterWidth;
      character.scale(scale);
      characterWidth *= scale;
      characterHeight *= scale;
    }
  }
  
  RPoint center = character.getCenter();
  character.rotate(rotation, center.x, center.y);
  
  if (anchorFinalBox)
  {
    if (setHeight > 0)
    {
      float scale = setHeight / character.getHeight();
      character.scale(scale);
      characterWidth *= scale;
      characterHeight *= scale;
    }
    else if (setWidth > 0)
    {
      float scale = setWidth / character.getWidth();
      character.scale(scale);
      characterWidth *= scale;
      characterHeight *= scale;
    }
    
    center = character.getCenter();
    characterWidth = character.getWidth();
    characterHeight = character.getHeight();
  }
  
  offsetX = - characterWidth * (anchorX - 0.5);
  offsetY = - characterHeight * (anchorY - 0.5);
  character.translate(x - center.x + offsetX, y - center.y + offsetY);
  
  return character;
}

void addChars(ArrayList<Character> list, char from, char to)
{
  for (char c = from; c <= to; c++)
  {
    list.add(c);
  }
}

void addChars(ArrayList<Character> list, String characters)
{
  for (int i = 0; i < characters.length(); i++)
  {
    list.add(characters.charAt(i));
  }
}

boolean randomBool(float trueChance)
{
  return random(1) < trueChance;
}

char random(ArrayList<Character> list)
{
  return list.get((int)random(list.size()));
}

MultiListElement random(ArrayList<Character>... lists)
{
  int count = 0;
  for (ArrayList<Character> list : lists)
  {
    count += list.size();
  }
  
  int index = (int)random(count);
  int listIndex = 0;
  for (ArrayList<Character> list : lists)
  {
    if (index < list.size())
    {
      return new MultiListElement(list.get(index), listIndex);
    }
    index -= list.size();
    listIndex++;
  }
  
  throw new RuntimeException();
}

void draw()
{
  //background(0);
  //drawImage();
}

void mouseWheel(MouseEvent event)
{
  /*
  int sectorX = (int)(mouseX - baseX) / sectorSize;
  int sectorY = (int)(mouseY - baseY) / sectorSize;
  sectorFontIndex[sectorX][sectorY] = (sectorFontIndex[sectorX][sectorY] - event.getCount() + fonts.size()) % fonts.size();
  drawSector(sectorX, sectorY);
  */
  
  fontIndex = (fontIndex - event.getCount() + fonts.size()) % fonts.size();
  println("Switched to: " + fonts.get(fontIndex));
  drawImage(true, false);
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    refresh();
  }
  else if (mouseButton == RIGHT)
  {
    int sectorX = (int)(mouseX - baseX) / sectorSize;
    int sectorY = (int)(mouseY - baseY) / sectorSize;
    sectorLocked[sectorX][sectorY] = !sectorLocked[sectorX][sectorY];
    if (sectorLocked[sectorX][sectorY])
    {
      lockedSectors++;
    }
    else
    {
      lockedSectors--;
    }
    drawImage(true, false);
  }
  else if (mouseButton == CENTER)
  {
    for (int x = 0; x < countX; x++)
    {
      for (int y = 0; y < countY; y++)
      {
        sectorLocked[x][y] = false;
      }
    }
    lockedSectors = 0;
    refresh();
  }
}

class Bounds
{
  float xMin;
  float xMax;
  float yMin;
  float yMax;
  float xCenter;
  float yCenter;
  float w;
  float h;
  
  Bounds()
  {
  }
  
  Bounds(float x, float y)
  {
    xMin = x;
    xMax = x;
    yMin = y;
    yMax = y;
    compute();
  }
  
  Bounds(Bounds a, Bounds b)
  {
    xMin = min(a.xMin, b.xMin);
    xMax = max(a.xMax, b.xMax);
    yMin = min(a.yMin, b.yMin);
    yMax = max(a.yMax, b.yMax);
  }
  
  Bounds(RGeomElem e)
  {
    RPoint topLeft = e.getTopLeft();
    RPoint bottomRight = e.getBottomRight();
    xMin = topLeft.x;
    yMin = topLeft.y;
    xMax = bottomRight.x;
    yMax = bottomRight.y;
    compute();
  }
  
  void compute()
  {
    xCenter = (xMin + xMax) / 2;
    yCenter = (yMin + yMax) / 2;
    w = xMax - xMin;
    h = yMax - yMin;
  }
}

class MultiListElement
{
  char c;
  int listIndex;
  
  MultiListElement(char c, int listIndex)
  {
    this.c = c;
    this.listIndex = listIndex;
  }
}
