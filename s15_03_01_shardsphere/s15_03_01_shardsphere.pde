/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

import processing.opengl.*;

float radius = 180;
int shardCount = 1150; 
float seed = 0;
int countdown = 0;
float fade = 50;

void setup()
{
  size(500, 500, OPENGL);
  background(255);
  stroke(0);
  frameRate(30);
  
  reset();
}

void draw()
{
  background(255);
  
  translate(width / 2, height / 2, 0);
  rotateY(frameCount * 0.01 + seed);
  rotateZ(seed);
  //rotateX(frameCount * 0.04);
  
  float a;
  if (countdown <= 0)
  {
    a = min(frameCount / fade, 1);
  }
  else
  {
    a = min(countdown / fade, 1);
    countdown--;
    if (countdown <= 0)
    {
      reset();
      a = 0;
    }
  }
  
  for (int i = 0; i < shardCount; i++)
  {
    beginShape();
    //float c = i;// + frameCount * 0.1;
    float c = i * 0.000005 * frameCount + seed;
    fill(noise(c, 0) * 255, noise(c, 1) * 255, noise(c, 2) * 255, 100 * a);
    stroke(255, 255, 255, 100 * a);
    
    for (int j = 0; j < 3; j++)
    { 
      float s = radians(noise(i, j * 0.1 + seed) * 360);
      float t = radians(noise(i * 2, j * 0.1 + seed) * 360);
      
      float factor = frameCount * 0.01;
      s *= factor * 1;
      //t *= factor * 0.1;
      //t += s * 0.1;
      
      //t *= min(frameCount / 100.0, 1);
      //s *= min(frameCount / 1000.0, 1);
      
      float x = cos(s) * sin(t);
      float y = sin(s) * sin(t);
      float z = cos(t);
      float r = radius;
      
      vertex(x * r, y * r, z * r);
    }
    
    endShape(CLOSE);
  }
}

void mouseClicked() {
  if (countdown <= 0)
  {
    countdown = min(frameCount, (int)fade);
  }
}

void reset()
{
  seed = random(100);
  frameCount = 0;
}
