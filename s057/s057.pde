/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to pause/resume.
*/

boolean paused;
float time;

float angle1;
float angle2;
float add1;
float add2;
float freq1;
float freq2;
float amp1;
float amp2;
float distance;
int mode;

void setup()
{
  //size(768, 768);
  fullScreen();
  blendMode(ADD);
  
  frameRate(130);
  reset();
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset();
  }
  else if (mouseButton == RIGHT)
  {
    paused = !paused;
  }
}

void keyPressed()
{
  switch (key)
  {
    case ' ': save("screenshot-" + frameCount + ".png"); break;
  }
}


void reset()
{
  noiseSeed(floor(random(0, 10000000)));

  add1 = random(0.01, 0.1);
  add2 = add1 * pow(2, (int)random(1, 4));
  
  freq1 = random(0.1, 1);
  freq2 = random(0.1, 1);
  amp1 = random(0, random(0, height/2));
  amp2 = random(amp1, height/2);
  
  print(add1 + " / " + freq1 + " / " + amp1);
  print(" --- ");
  println(add2 + " / " + freq2 + " / " + amp2);
  
  mode = (int)random(0, 2);
  
  time = 0;
  
  paused = false;
  
  background(0);
}

void draw()
{
  
  if (paused)
    return;
  
  for (int i = 0; i < 100; i++)
    step();
}

void step()
{
  time++;
  if (mode == 0)
  {
    angle1 += add1;
    angle2 += add2;
  }
  else
  {
    angle1 += add1/amp1;
    angle2 += add2/amp2;
  }
  float distance1 = cos(time * freq1) * amp1;
  float distance2 = sin(time * freq2) * amp2;
  
  stroke(255, 5);
  
  float cx = width/2;
  float cy = height/2;
  float offX1 = cos(angle1) * distance1;
  float offY1 = sin(angle1) * distance1;
  float offX2 = cos(angle2) * distance2;
  float offY2 = sin(angle2) * distance2;
  line(cx + offX1, cy + offY1, cx + offX2, cy + offY2);
}