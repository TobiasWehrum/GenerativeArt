/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to ???.
- Right-click to ???.

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

boolean useGradient = true;
String gradientFilename = "gradientBlue1.png"; //"gradientHue240-480.png";
color[] gradient;

String paletteFileName = "selected2";
ArrayList<Palette> palettes;
Palette currentPalette;
boolean paletteLock = false;

ArrayList<ArrayList<ColorPatch>> colorPatchList = new ArrayList<ArrayList<ColorPatch>>();

PGraphics pg;

int factor = 1;

void setup()
{
  size(768, 768, P3D);
  
  pg = createGraphics(width*factor, height*factor, P3D);
  
  //fullScreen();
  //colorMode(HSB, 360, 100, 100, 100);
  
  gradient = loadGradient(gradientFilename);

  if (palettes == null)
  {
    palettes = loadPalettes(paletteFileName, false);
  }
  
  reset();
}

void reset()
{
  if (!paletteLock)
  {
    currentPalette = palettes.get((int)random(palettes.size()));
  }
  
  currentPalette = new Palette();
  currentPalette.addColor(color(0, 0, 0), 0);
  currentPalette.addColor(color(231, 3, 4), 15);
  currentPalette.addColor(color(229, 92, 0), 10);
  currentPalette.addColor(color(244, 223, 78), 2.5);
  currentPalette.addColor(color(209, 194, 7), 2.5);
  currentPalette.addColor(color(210, 209, 155), 1);
  currentPalette.addColor(color(61, 223, 164), 1);
  currentPalette.addColor(color(55, 153, 138), 1);
  currentPalette.addColor(color(52, 83, 114), 1);
  currentPalette.addColor(color(30, 23, 101), 1);
  currentPalette.addColor(color(136, 52, 114), 1);
  
  color primaryColor = currentPalette.randomColor();
  float primaryColorChance = 0;
  
  colorPatchList.clear();
  for (int j = 0; j < 2; j++)
  {
    ArrayList<ColorPatch> colorPatches = new ArrayList<ColorPatch>();
    colorPatchList.add(colorPatches);
    
    int colorPatchCount = (int)(random(0.013, 0.039) * pg.width);
    for (int i = 0; i < colorPatchCount; i++)
    {
      color c = currentPalette.randomColor();
      //color c = getColor(gradient, random(0, 1));
      if (random(1) < primaryColorChance)
        c = primaryColor;
      colorPatches.add(new ColorPatch(random(0, pg.width), random(0, pg.height), c));
    }
  }
  
  noiseSeed((int)random(0, 1000000));
  
  render();
}

void draw()
{
}

void keyPressed()
{
  switch (key)
  {
//    case 'q': variationIndexMove(0, 1); break;
    case ' ': pg.save("screenshot-" + frameCount + ".png"); break;
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset();
  }
  else if (mouseButton == CENTER)
  {
  }
  else if (mouseButton == RIGHT)
  {
  }
}

color getColor(float percent)
{
  return useGradient ? getColor(gradient, percent) : currentPalette.getPercent(percent);
}

void render()
{
  pg.beginDraw();
  pg.background(0);
  //pg.blendMode(ADD);
  
  //noiseSeed(0);
  
  float colorOffset = 70;
  int count = (int)(0.3*pg.width);
  for (int i = 0; i < count; i++)
  {
    float percent = (float)i/count;
    PVector position = new PVector(random(0, pg.width), random(0, pg.height));
    float angle = random(0, PI*2);
    float angleSpeed = random(-1, 1) * PI / 60;
    float stepDistance = 15;
    
    ArrayList<ColorPatch> colorPatches = colorPatchList.get((int)(random(colorPatchList.size())));
    
    Path path = new Path();
    path.addPoint(position);
    int stepCount = (int)random(100, 200);
    float colorOffsetX = random(-colorOffset, colorOffset);
    float colorOffsetY = random(-colorOffset, colorOffset);
    float randomColor = 50;
    for (int j = 0; j < stepCount; j++)
    {
      position.x += Math.cos(angle) * stepDistance;
      position.y += Math.sin(angle) * stepDistance;
      PathPoint p = path.addPoint(position);
      color c = getClosestColor(position.x + colorOffsetX, position.y + colorOffsetY, colorPatches);
      c = color((red(c) + random(-randomColor, randomColor)) * percent,
                (green(c) + random(-randomColor, randomColor)) * percent,
                (blue(c) + random(-randomColor, randomColor)) * percent);
      p.c = c;
      angle += angleSpeed;
    }
    
    pg.strokeWeight(1);
    pg.stroke(255, 20);
    pg.noStroke();
    
    //renderPathStrip(path, 5);
    float noiseSpeed = 0.01;
    
    for (int j = 0; j < 15; j++)
    {
      renderAdjecentPath(j, noiseSpeed, path, 0.023*pg.width, 0.023*pg.width, 100);
    }
  }
  pg.endDraw();
  
  image(pg, 0, 0, width, height);
}

void renderAdjecentPath(float noiseIndex, float noiseSpeed, Path originalPath, float maxOffsetTotal, float maxOffset,
                        float fillAlpha)
{
  float offsetTotalX = (noise(noiseIndex, -1, 0) * 2 - 1) * maxOffsetTotal;
  float offsetTotalY = (noise(noiseIndex, -1, 1) * 2 - 1) * maxOffsetTotal;
  Path newPath = new Path();
  float noisePoint = 0;
  float randomColor = 50;
  for (PathPoint point : originalPath.points)
  {
    float offsetX = (noise(noiseIndex, noisePoint, 0) * 2 - 1) * maxOffset + offsetTotalX;
    float offsetY = (noise(noiseIndex, noisePoint, 1) * 2 - 1) * maxOffset + offsetTotalY;
    noisePoint += noiseSpeed;
    
    PathPoint newPoint = newPath.addPoint(new PVector(point.position.x + offsetX, point.position.y + offsetY));
    color c = color(red(point.c) + random(-randomColor, randomColor),
                    green(point.c) + random(-randomColor, randomColor),
                    blue(point.c) + random(-randomColor, randomColor));
    newPoint.c = point.c;
  }
  renderPathStrip(newPath, 2 * factor, fillAlpha);
  //renderPathSand(newPath, 5 * factor, fillAlpha);
}

void renderPathStrip(Path path, float lineWidth, float fillAlpha)
{
  PVector out = new PVector();
  pg.beginShape();
  for (PathPoint point : path.points)
  {
    point.getTangentPoint(true, lineWidth, out);
    pg.fill(point.c, fillAlpha);
    pg.vertex(out.x, out.y);
  }
  
  for (int i = path.points.size() - 1; i >= 0; i--)
  {
    PathPoint point = path.points.get(i);
    point.getTangentPoint(false, lineWidth, out);
    pg.fill(point.c, fillAlpha);
    pg.vertex(out.x, out.y);
  }
  pg.endShape(CLOSE);
}

void renderPathSand(Path path, float lineWidth, float alpha)
{
  PVector out1 = new PVector();
  PVector out2 = new PVector();
  pg.noFill();
  for (PathPoint point : path.points)
  {
    point.getTangentPoint(true, lineWidth, out1);
    point.getTangentPoint(false, lineWidth, out2);
    pg.stroke(point.c, alpha);
    pg.line(out1.x, out1.y, out2.x, out2.y);
  }
}

color getClosestColor(float x, float y, ArrayList<ColorPatch> colorPatches)
{
  float closestDistanceSq = Float.POSITIVE_INFINITY;
  ColorPatch closestColorPatch = null;
  
  for (ColorPatch patch : colorPatches)
  {
    float distanceSq = patch.distanceSq(x, y);
    if (distanceSq < closestDistanceSq)
    {
      closestDistanceSq = distanceSq;
      closestColorPatch = patch;
    }
  }
  
  return closestColorPatch.c;
}

class ColorPatch
{
  PVector position;
  color c;
  
  ColorPatch(float x, float y, color c)
  {
    position = new PVector(x, y);
    this.c = c;
  }
  
  public float distanceSq(float x, float y)
  {
    float dx = position.x - x;
    float dy = position.y - y;
    return dx * dx + dy * dy;
  }
}