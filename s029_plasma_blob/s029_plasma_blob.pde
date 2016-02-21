/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

color c;

void setup()
{
  size(500, 500, P2D);
  colorMode(HSB, 360, 1, 1, 255);
  blendMode(ADD);
  reset();
}

void reset()
{
  c = color(random(360), 1, 1);
  noiseSeed((int) random(1000000));
}

void draw()
{
  background(0);
  
  noStroke();
  fill(c, 3);
  
  for (int j = 0; j < 200; j++)
  {
    beginShape();
    int t = 0;
    
    float time = frameCount * 0.005;
    float time2 = frameCount * 0.002;
    
    float x = noise(j * 5, t+ time,  time2) * width;
    float y = noise(j * 5, t + 10+ time,  time2) * height;
    
    x -= width / 10;
    y -= height / 10;
    
    float randomVariation = 200;
    float r1 = noise(j * 5, 0+ time,  time2) * randomVariation - randomVariation / 2;
    float r2 = noise(j * 5, 1+ time,  time2) * randomVariation - randomVariation / 2;
    float r3 = noise(j * 5, 2+ time,  time2) * randomVariation - randomVariation / 2;
    float r4 = noise(j * 5, 3+ time,  time2) * randomVariation - randomVariation / 2;
    float r5 = noise(j * 5, 4+ time,  time2) * randomVariation - randomVariation / 2;
    float r6 = noise(j * 5, 5+ time,  time2) * randomVariation - randomVariation / 2;
    float r7 = noise(j * 5, 6+ time,  time2) * randomVariation - randomVariation / 2;
    float r8 = noise(j * 5, 7+ time,  time2) * randomVariation - randomVariation / 2;
    
    vertex(x + r1, y + r2);
    vertex(x + r3, height - y + r4);
    vertex(width - x + r5, height - y + r6);
    vertex(width - x + r7, y + r8);
    endShape(CLOSE);
  }
}

void mouseClicked()
{
  reset();
}