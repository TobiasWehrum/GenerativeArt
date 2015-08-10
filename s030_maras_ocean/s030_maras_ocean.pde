/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click or X to refresh.
- Right-click or C to refresh, but keep color palette.
- Middle-click or V to refresh, but switch colors.
*/

import geomerative.*;

ArrayList<String> fonts = new ArrayList<String>();
ArrayList<Float> fontScaleMultipliers = new ArrayList<Float>();
int fontIndex = 0;
float fontScaleMultiplier;

color landColor1;
color landColor2;
color waterColor1;
color waterColor2;

String font;

ArrayList<Character> chars = new ArrayList<Character>();

float scale = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  //scaledSize(500, 500, 500, 500);
  scaledSize(500, 500, displayWidth, displayHeight);
  smooth();
  colorMode(HSB, 360, 1, 1, 1);
  //blendMode(ADD);
  
  fonts.add("Mara's Eye.ttf");
  fontScaleMultipliers.add(1.0);
  
  addChars(chars, 'a', 'z');
  addChars(chars, 'A', 'Z');

  RG.init(this);
  
  font = fonts.get(0);
  fontScaleMultiplier = fontScaleMultipliers.get(0);

  refresh(true);
}

void refresh(boolean refreshColors)
{
  noiseSeed((int) random(1000000));

  if (refreshColors)
  {
    float landBrightness = random(0.5, 1);
    float waterBrightness = random(0.5, 1);
    
    if (landBrightness < waterBrightness)
    {
      float t = landBrightness;
      landBrightness = waterBrightness;
      waterBrightness = t;
    }
    
    float waterHue = random(360);
    float waterSaturation = random(0.1, 1);
    float landHue = random(360);
    //float landHue2 = random(360);
    float landSaturation = random(0.1, 1);
    
    waterColor1 = color(waterHue, waterSaturation, waterBrightness, 0.5);
    //waterColor2 = color(waterHue, waterSaturation, waterBrightness, 0.5);
    landColor1 = color(landHue, landSaturation, landBrightness);
    landColor2 = color(landHue, 0, 1);
  }

  background(0);
  
  step();
}

void step()
{
  float distance = 15 * scale;
  
  float positionNoise = 10;
  
  float noiseScale = 0.01 * (500.0/displayWidth) * random(0.5, 2.5);
  //float landHeight = random(0.55, 0.65);
  float landHeight = 0.6;
  
  int characterSize = (int)(50 * scale);
  
  int extraPadding = 5;
  float startX = -distance / 2 - distance * extraPadding;
  float startY = startX;
  float endX = width + distance * (extraPadding + 1);
  float endY = height + distance * (extraPadding + 1);
  
  //RGeomElem character = createCharacter('A', 0, 0, 0, characterSize);
  
  RGeomElem waterCharacter = createCharacter(random(chars), 0, 0, 0, characterSize);
  
  RGeomElem[] characters = new RGeomElem[10];
  for (int i = 0; i < characters.length; i++)
  {
    characters[i] = createCharacter(random(chars), 0, 0, 0, characterSize);
  }
  
  for (float x = startX; x < endX; x += distance)
  {
    for (float y = startY; y < endY; y += distance)
    {
      float px = x + random(-positionNoise, positionNoise);
      float py = y + random(-positionNoise, positionNoise);
      float h = noise(x * noiseScale, y * noiseScale);
      float r = noise(x * noiseScale, y * noiseScale, 10) * TWO_PI;
      boolean land = h >= landHeight;
      //color c = land ? landColor : waterColor;
      //c = color(0, 0, p.h, 1);
      
      //drawCharacter('a', px, py, 0, characterSize);

      RGeomElem character;
      
      color c;      
      float t;
      if (land)
      {
        t = min(norm(h, landHeight, 0.9), 1);
        c = lerpColor(landColor1, landColor2, t);
        int charactersIndex = min((int)(t * characters.length), characters.length - 1);
        character = characters[charactersIndex];
      }
      else
      {
        //t = norm(h, 0, landHeight);
        //c = lerpColor(waterColor1, waterColor2, t);
        c = waterColor1;
        character = waterCharacter;
      }
      
      stroke(0, 0.3);
      fill(c);

      //int charactersIndex = min((int)(h * characters.length), characters.length - 1);
      //character = characters[charactersIndex];
      
      drawCharacter(character, px, py, r);
    }
  }
}

void draw()
{
}

void keyPressed()
{
  if (key == 'x')
  {
    refresh(true);
  }
  else if (key == 'c')
  {
    refresh(false);
  }
  else if (key == 'v')
  {
    switchColors();
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    refresh(true);
  }
  else if (mouseButton == RIGHT)
  {
    refresh(false);
  }
  else if (mouseButton == CENTER)
  {
    switchColors();
  }
}

void switchColors()
{
  color temp = landColor1;
  landColor1 = waterColor1;
  waterColor1 = temp;
  temp = landColor2;
  landColor2 = waterColor2;
  waterColor2 = temp;
  refresh(false);
}

void drawCharacter(char c, float x, float y, float rotation, int size)
{
  drawCharacter(c, x, y, 0.5, 0.5, rotation, 0, 0, false, false, false, size);
}

void drawCharacter(RGeomElem character, float x, float y, float rotation)
{
  pushMatrix();
  translate(x, y);
  rotate(rotation);
  
  character.draw();
  
  popMatrix();
}

RGeomElem createCharacter(char c, float x, float y, float rotation, int size)
{
  return createCharacter(c, x, y, 0.5, 0.5, rotation, 0, 0, false, false, false, size);
}

void drawCharacter(char c, float x, float y, float anchorX, float anchorY, float rotation, float setWidth,
                     float setHeight, boolean anchorFinalBox, boolean mirrorX, boolean mirrorY, int size)
{
  RGeomElem character = createCharacter(c, x, y, anchorX, anchorY, rotation, setWidth, setHeight, anchorFinalBox,
                                        mirrorX, mirrorY, size);
                                        
  if (character == null)
    return;

  character.draw();
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

char random(ArrayList<Character> list)
{
  return list.get((int)random(list.size()));
}

