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

void setup()
{
  size(768, 768, P3D);
  //fullScreen();
  //blendMode(ADD);
  //colorMode(HSB, 360, 100, 100, 255);
  
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
  
  background(0);
  render();
}

void keyPressed()
{
  switch (key)
  {
//    case 'q': variationIndexMove(0, 1); break;
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
  stroke(255);
  fill(50);
  
  beginShape();
  vertex(100, 100);
  vertex(600, 100);
  vertex(600, 150);
  vertex(100, 150);
  endShape();
  
  stroke(255);
  fill(0, 0, 255);

  beginShape();
  vertex(250, 175, -1);
  vertex(350, 75, -1);
  vertex(400, 75, -1);
  vertex(250, 225, -1);
  vertex(250, 225, 1);
  vertex(100, 75, 1);
  vertex(150, 75, 1);
  vertex(250, 175, 1);
  endShape();
}