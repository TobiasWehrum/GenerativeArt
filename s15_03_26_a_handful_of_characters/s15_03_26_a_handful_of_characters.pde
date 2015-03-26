/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to switch between modes (mirror, circular)
- Mouse wheel or +/- to change font.
*/

import geomerative.*;

ArrayList<String> fonts = new ArrayList<String>();
ArrayList<Float> fontScaleMultipliers = new ArrayList<Float>();
int fontIndex = 0;
int mode = 0;

float scale = 1;
float fontScaleMultiplier;

int seed;

String font;

ArrayList<Character> chars = new ArrayList<Character>();

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  int side = 500;
  scaledSize(500, 500, side, side);
  colorMode(HSB, 255);
  smooth();
  
  fonts.add("Mara's Eye.ttf");
  fontScaleMultipliers.add(1.0);
  
  fonts.add("Mara's Eye.ttf");
  fontScaleMultipliers.add(1.4);
  
  fonts.add("Mage Script.ttf");
  fontScaleMultipliers.add(1.0);
  
  fonts.add("Iokharic.otf");
  fontScaleMultipliers.add(1.4);
  
  fonts.add("Visitor Script.ttf");
  fontScaleMultipliers.add(0.9);
  
  fonts.add("WereWolf.ttf");
  fontScaleMultipliers.add(1.3);
  
  fonts.add("Tribalz.ttf");
  fontScaleMultipliers.add(0.7);
  
  fonts.add("FreeSans.ttf");
  fontScaleMultipliers.add(1.0);
  
  
  addChars(chars, 'a', 'z');
  addChars(chars, 'A', 'Z');
  //addChars(chars, '0', '9');
  //addChars(chars, ".,:;'\"#$&*+-=_|~()[]?!{}");
  
  RG.init(this);
  
  font = fonts.get(0);
  fontScaleMultiplier = fontScaleMultipliers.get(0);

  refresh();
  //debugDraw();
}

void refresh()
{
  drawImage(true);
}

void debugDraw()
{
  background(0);
  drawCharacter('B', width / 2, height / 2, 0, 0.5, 0, 0, 0, false, false, false, 72);
  stroke(255);
  line(width / 2, 0, width / 2, height);
  line(0, height / 2, width, height / 2);
}

void drawImage(boolean randomize)
{
  if (randomize)
  {
    seed = (int) random(100000) + frameCount;
  }
  
  randomSeed(seed);
  
  font = fonts.get(fontIndex);
  fontScaleMultiplier = fontScaleMultipliers.get(fontIndex);
  
  background(0);
  noStroke();
  fill(255);
  
  if (mode == 0)
  {
    drawLettersGrid();
  }
  else
  {
    drawLettersCircle();
  }
}

void drawLettersCircle()
{
  int instanceCount = (int) random(4, 13);
  float angleOffset = TWO_PI / instanceCount;
  
  pushMatrix();
  translate(width / 2, height / 2);
  
  for (float i = 0.5; i < width / 2; i += 30 * scale)
  {
    drawLetterCircle(i, instanceCount, angleOffset);
  }
  
  popMatrix();
}

void drawLettersGrid()
{
  int countX = 5;
  int countY = 5;
  float offsetX = (float)width / countX / 2.0;
  float offsetY = (float)height / countY / 2.0;
  
  for (int x = 0; x < countX; x++)
  {
    for (int y = 0; y < countY; y++)
    {
      drawLetterGrid((x + 0.5) * offsetX, (y + 0.5) * offsetY);
    }
  }
}

void drawLetterGrid(float x, float y)
{
  float offset = 10 * scale;
  x += random(-offset, offset);
  y += random(-offset, offset);
  
  char c = random(chars);
  float rotation = random(0, TWO_PI);
  boolean mirrorX = randomBool(0.5);
  boolean mirrorY = randomBool(0.5);
  
  int size = (int)(random(50, 120) * scale);
  
  drawCharacter(c, x, y, 0.5, 0.5, rotation, 0, 0, true, mirrorX, mirrorY, size);
  drawCharacter(c, width - x, y, 0.5, 0.5, rotation, 0, 0, true, !mirrorX, mirrorY, size);
  drawCharacter(c, x, height - y, 0.5, 0.5, rotation, 0, 0, true, mirrorX, !mirrorY, size);
  drawCharacter(c, width - x, height - y, 0.5, 0.5, rotation, 0, 0, true, !mirrorX, !mirrorY, size);
}

void drawLetterCircle(float distance, int instanceCount, float angleOffset)
{
  float baseAngle = random(0, angleOffset);
  
  //float offset = 10 * scale;
  //distance += random(-offset, offset);
  
  char c = random(chars);
  float rotation = random(0, TWO_PI);
  boolean mirrorX = randomBool(0.5);
  boolean mirrorY = randomBool(0.5);
  
  int size = (int)(random(50, 120) * scale);
  
  for (int i = 0; i < instanceCount; i++)
  {
    float a = baseAngle + i * angleOffset;
    float x = cos(a) * distance;
    float y = sin(a) * distance;
    drawCharacter(c, x, y, 0.5, 0.5, rotation + a, 0, 0, true, mirrorX, mirrorY, size);
  }
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
                     float setHeight, boolean anchorFinalBox, boolean mirrorX, boolean mirrorY, int size)
{
  RGeomElem character = createCharacter(c, x, y, anchorX, anchorY, rotation, setWidth, setHeight, anchorFinalBox,
                                        mirrorX, mirrorY, size);
                                        
  if (character == null)
    return new Bounds();

  character.draw();
  return new Bounds(character);
}

RGeomElem createCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation, float setWidth,
                          float setHeight, boolean anchorFinalBox, boolean mirrorX, boolean mirrorY, int size)
{
  RShape group = RG.getText(c + "", font, (int)(size * fontScaleMultiplier), LEFT);
  if ((group == null) || (group.children == null) || (group.children.length == 0))
  {
    return null;
  }
  RGeomElem character = group.children[0];
  
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

  character.scale((mirrorX ? -1 : 1), (mirrorY ? -1 : 1));

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

void keyPressed()
{
  if (key == '+')
  {
    updateFont(1);
  }
  else if (key == '-')
  {
    updateFont(-1);
  }
}

void mouseWheel(MouseEvent event)
{
  /*
  int sectorX = (int)(mouseX - baseX) / sectorSize;
  int sectorY = (int)(mouseY - baseY) / sectorSize;
  sectorFontIndex[sectorX][sectorY] = (sectorFontIndex[sectorX][sectorY] - event.getCount() + fonts.size()) % fonts.size();
  drawSector(sectorX, sectorY);
  */
  
  updateFont(-event.getCount());
}

void updateFont(int delta)
{
  fontIndex = (fontIndex + delta + fonts.size()) % fonts.size();
  println("Switched to: " + fonts.get(fontIndex) + "(" + fontScaleMultipliers.get(fontIndex) + ")");
  drawImage(false);
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    refresh();
  }
  else if (mouseButton == RIGHT)
  {
    mode = (mode + 1) % 2;
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
