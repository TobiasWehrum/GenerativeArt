import geomerative.*;

String font = "FreeSans.ttf";
int size = 72;

float scale = 1;

ArrayList<Character> charsNoseUnrotated = new ArrayList<Character>();
ArrayList<Character> charsNoseRotated = new ArrayList<Character>();
ArrayList<Character> charsNoseAny = new ArrayList<Character>();

ArrayList<Character> charsEyesCompleteRotated = new ArrayList<Character>();
ArrayList<Character> charsEyesSingle = new ArrayList<Character>();

ArrayList<Character> charsMouthUnrotated = new ArrayList<Character>();
ArrayList<Character> charsMouthRotated = new ArrayList<Character>();
ArrayList<Character> charsMouthAny = new ArrayList<Character>();

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
  
  RG.init(this);
  
  refresh();
}

void refresh()
{
  background(0);
  drawImage();
}

void drawImage()
{
  int sectorSize = height / 3;
  int countX = width / sectorSize;
  int countY = height / sectorSize;
  float baseX = (width - (countX * sectorSize)) / 2;
  float baseY = (height - (countY * sectorSize)) / 2;
  
  /*
  float brightnessBackgroundA = random(0, 50);
  float brightnessEmoticonA = 255;
  if (random(1) < 0.5)
  {
    brightnessBackgroundA = 255 - brightnessBackgroundA;
    brightnessEmoticonA = 255 - brightnessEmoticonA;
  }
  
  float brightnessBackgroundB = random(0, 50);
  float brightnessEmoticonB = 255;
  if (random(1) < 0.5)
  {
    brightnessBackgroundB = 255 - brightnessBackgroundB;
    brightnessEmoticonB = 255 - brightnessEmoticonB;
  }
  */
  
  int index = 0;
  
  for (int x = 0; x < countX; x++)
  {
    for (int y = 0; y < countY; y++)
    {
      float brightnessBackground = random(0, 50);
      float brightnessEmoticon = 255;
      if (random(1) < 0.5)
      {
        brightnessBackground = 255 - brightnessBackground;
        brightnessEmoticon = 255 - brightnessEmoticon;
      }
      
      fill(0, 0, brightnessBackground);
      //fill(0, 0, ((index % 2) == 0) ? brightnessBackgroundA : brightnessBackgroundB);
      rect(baseX + x * sectorSize, baseY + y * sectorSize, sectorSize, sectorSize);
      
      fill(0, 0, brightnessEmoticon);
      //fill(0, 0, ((index % 2) == 0) ? brightnessEmoticonA : brightnessEmoticonB);
      drawEmoticon(baseX + (x + 0.5) * sectorSize, baseY + (y + 0.5) * sectorSize, scale * 1.5 / countY);

      index++;
    }
  }

  //drawCharacter('I', width / 2, height / 2, 0.5, 0, PI / 2, 0, true);
  //stroke(255);
  //line(width / 2, 0, width / 2, height);
  //line(0, height / 2, width, height / 2);
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
  return drawCharacter(element.c, 0, 0, 0.5, 0.5, angle, setHeight, true);
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
  return drawCharacter(random(charsEyesCompleteRotated), 0, maxLineY,  0.5, 1, PI / 2);
}

Bounds drawEyesSingle(float maxLineY, float emoticonScale)
{
  char charA = random(charsEyesSingle);
  char charB = (random(1) < 0.5) ? charA : random(charsEyesSingle);
  float rotationA = random(0, TWO_PI);
  float rotationB = 0;
  if (random(1) < 0.95)
  {
    rotationB = (random(1) < 0.5) ? rotationA : -rotationA; 
  }
  else
  {
    rotationB = random(0, TWO_PI);
  }
  
  float distMin = 10 * emoticonScale;
  float distMay = 50 * emoticonScale;
  
  float distanceFromCenterA = random(distMin, distMay);
  float distanceFromCenterB = (random(1) < 0.95) ? distanceFromCenterA : random(distMin, distMay);
  
  float eyeHeightMin = 10 * emoticonScale;
  float eyeHeightMay = 30 * emoticonScale;
  
  float eyeHeightA = random(eyeHeightMin, eyeHeightMay); 
  float eyeHeightB = (random(1) < 0.95) ? eyeHeightA : random(eyeHeightMin, eyeHeightMay);
  
  Bounds boundsA = drawCharacter(charA, -distanceFromCenterA, maxLineY, 0.5, 1, rotationA, eyeHeightA, true);
  Bounds boundsB = drawCharacter(charB, distanceFromCenterB, maxLineY, 0.5, 1, rotationB, eyeHeightB, true);
  return new Bounds(boundsA, boundsB);
}

Bounds drawMouth(float maxLineY, float emoticonScale)
{
  maxLineY += random(5, 20) * emoticonScale;
  
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
  return drawCharacter(element.c, 0, maxLineY, 0.5, 0, angle, 0, true);
}

Bounds drawCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation)
{
  return drawCharacter(c, x, y, anchorX, anchorY, rotation, 0);
}

Bounds drawCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation, float setHeight)
{
  return drawCharacter(c, x, y, anchorX, anchorY, rotation, setHeight, false);
}

Bounds drawCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation, float setHeight, boolean anchorFinalBox)
{
  RShape group = RG.getText(c + "", font, size, LEFT);
  RGeomElem character = group.children[0];
  
  float offsetX = 0;
  float offsetY = 0;
  float characterWidth = character.getWidth();
  float characterHeight = character.getHeight();
  
  if ((setHeight > 0) && !anchorFinalBox)
  {
    float scale = setHeight / characterHeight;
    character.scale(scale);
    characterWidth *= scale;
    characterHeight *= scale;
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
    
    center = character.getCenter();
    characterWidth = character.getWidth();
    characterHeight = character.getHeight();
  }
  
  offsetX = - characterWidth * (anchorX - 0.5);
  offsetY = - characterHeight * (anchorY - 0.5);
  character.translate(x - center.x + offsetX, y - center.y + offsetY);
  
  pushMatrix();
  group.draw();
  popMatrix();
  
  return new Bounds(character);
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

void mouseClicked()
{
  refresh();
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
