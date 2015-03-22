/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to refresh, but keep palette.
*/

import java.util.Collections;

String paletteFileName = "topPicked";

boolean wrap = false;
int side;
int raster;
int sliceCount;

ArrayList<Integer> colors;

boolean paused = false;

ArrayList<Palette> palettes;
Palette currentPalette;

float scale = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight)
{
  size(desiredWidth, desiredHeight);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  //side = 500;
  //side = 1080;
  side = min(displayWidth, displayHeight);
  scaledSize(500, 500, side, side);
  //smooth();
  
  paused = false;
  
  if (palettes == null)
  {
    palettes = new ArrayList<Palette>();
    loadPalettes();
  }
  
  chooseColors();
  reset();
}

void chooseColors()
{
  int paletteIndex = (int)random(palettes.size());
  currentPalette = palettes.get(paletteIndex);
  println("Palette: " + currentPalette.name);
  
  colors = new ArrayList<Integer>(currentPalette.colors);
  Collections.shuffle(colors);
}

void reset()
{
  noiseSeed((int) random(100000));

  raster = 1;
  sliceCount = side / raster;
  
  frameCount = 0;
  
  //background(255);
  int halfSide = side / 2;
  
  noStroke();
  
  /*
  translate(halfWidth, halfHeight);
  rotate(random(PI * 2));
  translate(-halfWidth, -halfHeight);
  */
  
  color upLeft = colors.get(0);
  color upRight = colors.get(1);
  color downLeft = colors.get(2);
  color downRight = colors.get(3);
  
  /*
  fill(upLeft);
  rect(-halfSide, -halfSide, side, side);

  fill(upRight);
  rect(halfSide, -halfSide, side, side);

  fill(downLeft);
  rect(-halfSide, halfSide, side, side);

  fill(downRight);
  rect(halfSide, halfSide, side, side);
  */
  
  for (int x = 0; x < side; x++)
  {
    float t = (float)x / side;
    
    stroke(lerpColor(upLeft, upRight, t));
    line(x, 0, x, halfSide);
    
    stroke(lerpColor(downLeft, downRight, t));
    line(x, halfSide, x, side);
  }
  
  loadPixels();
  
  int shiftCount = randomIntInclusive(0, 15);
  for (int i = 0; i < shiftCount; i++)
  {
    executeShift(0, true);
  }
  
  int buildingCount = randomIntInclusive(5, 10);
  for (int i = 0; i < buildingCount; i++)
  {
    //executeShift((int) random(4), false);
    executeShift(3, false);
  }
  updatePixels();
}

/*
Method:
- 0 = normal
- 1 = increasing
- 2 = decreating
- 3 = bridge
*/
void executeShift(int method, boolean horizontal)
{
  int shiftCount = randomIntInclusive(25 * scale / raster, 100 * scale / raster);
  int shiftDistance = randomIntInclusive(15 * scale / raster, 100 * scale / raster);
  int startRow = randomRow(shiftCount - 1);
  int direction = randomDirection();
  
  if (method == 2)
  {
    shiftDistance += shiftCount - 1;
  }
  
  int pivotA = (shiftCount / 2);
  int pivotB = pivotA;
  if (shiftCount % 2 == 0)
  {
    pivotA--;
  }
  
  for (int i = 0; i < shiftCount; i++)
  {
    rasterShift(horizontal, startRow + i, direction, shiftDistance);

    if (method == 1)
    {
      shiftDistance++;
    }
    else if (method == 2)
    {
      shiftDistance--;
    }
    else if (method == 3)
    {
      if (i < pivotA)
      {
        shiftDistance++;
      }
      else if (i >= pivotB)
      {
        shiftDistance--;
      }
    }
  }
}

void groupShift()
{
  
}

boolean randomBoolean()
{
  return random(1) < 0.5;
}

int randomRow()
{
  return randomRow(0);
}

int randomRow(int endBorder)
{
  return (int) random(0, sliceCount - endBorder);
}

int randomIntInclusive(float minInclusive, float maxInclusive)
{
  return (int) random(minInclusive, maxInclusive + 1);
}

int randomIntInclusive(int minInclusive, int maxInclusive)
{
  return (int) random(minInclusive, maxInclusive + 1);
}

int randomDirection()
{
  return randomBoolean() ? 1 : -1;
}

void rasterShift(boolean horizontal, int row, int direction, int shiftLength)
{
  for (int loop = 0; loop < raster * shiftLength; loop++)
  {
    for (int offset = 0; offset < raster; offset++)
    {
      singleShift(horizontal, row * raster + offset, direction);
    }
  } 
}

void singleShift(boolean horizontal, int row, int direction)
{
  int startIndex = 0;
  int indexDelta = 0;
  if (horizontal)
  {
    if (direction > 0)
    {
      startIndex = row * side;
      indexDelta = 1;
    }
    else if (direction < 0)
    {
      startIndex = (side - 1) + row * side;
      indexDelta = -1;
    }
  }
  else
  {
    if (direction > 0)
    {
      startIndex = row;
      indexDelta = side;
    }
    else if (direction < 0)
    {
      startIndex = row + (side - 1) * side;
      indexDelta = -side;
    }
  }
  
  int index = startIndex;
  int startColor = pixels[index];
  for (int i = 0; i < side - 1; i++)
  {
    pixels[index] = pixels[index + indexDelta];
    index += indexDelta;
  }
  
  if (wrap)
  {
    pixels[index] = startColor;
  }
}

void draw()
{
  /*
  if (paused)
  {
    frameCount--;
    return;
  }
  */
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    chooseColors();
    reset();
  }
  else if (mouseButton == RIGHT)
  {
    reset();
  }
}

void loadPalettes()
{
  XML xml = loadXML(paletteFileName + ".xml");
  XML[] children = xml.getChildren("palette");
  for (XML child : children)
  {
    Palette palette = new Palette(child.getChild("title").getContent());
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
  String name;
  ArrayList<Integer> colors = new ArrayList<Integer>();
  ArrayList<Float> widths = new ArrayList<Float>();
  float totalWidth = 0;
  
  Palette(String name)
  {
    this.name = name;
  }
  
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
