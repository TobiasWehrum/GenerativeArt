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
  colorMode(HSB, 255);
  frameRate(30);
  reset();
}

void draw()
{
  randomSeed((int)seed);
  noiseSeed((int)seed);
  
  float _a = random(1);
  float _b = random(1);
  float _c = random(1);
  float _d = random(1);
  
  //_a = 0; _b = 0; _c = 0; _d = 1;
  _d += 1;  
  
  //background(255);
  
  background(0);

  directionalLight(0, 0, 255, -0.3, 0.5, -0.5);
  
  pushMatrix();
  //translate(100, 100, 0);
  translate(width / 2, height / 2, 0);
  //lights();
  //rotateY(frameCount * 0.01 + seed);
  //rotateZ(seed);
  //rotateX(frameCount * 0.04);
  float ri = frameCount * 0.003;
  rotateX(noise(ri, 0) * PI * 2); 
  rotateY(noise(ri, 10) * PI * 2 + frameCount * 0.02);
  rotateZ(noise(ri, 20) * PI * 2);

  float blockCount = 60;
  //float dS = PI * 2 / 100f;
  //float dT = PI / 100f;
  float dT = PI / blockCount;
  
  //float c = i;// + frameCount * 0.1;
  //float c = 0.000005 * frameCount + seed;
  float c = 0;
  //fill(noise(c, 0) * 255, noise(c, 1) * 255, noise(c, 2) * 255);
  //fill(noise(c, 0) * 2550 % 255, 255, 255);
  //stroke(255, 255, 255);
  noStroke();
  
  for (float t = 0; t <= PI; t += dT)
  {
    float z = cos(t);
    //float distanceToCenter = abs(z);
    float count = max(sin(t) * blockCount, 1);
    float dS = PI * 2 / count;
    //dS = lerp(0.3, 0.1, 1 - distanceToCenter);
    for (float s = 0; s <= PI * 2; s += dS)
    {
      float x = cos(s) * sin(t);
      float y = sin(s) * sin(t);
      float r = radius;
      
      pushMatrix();
      translate(x * r, y * r, z * r);
      float index = s*321 + t*123 + frameCount * 0.01;
      rotateX(noise(index, 0) * PI * 2); 
      rotateY(noise(index, 10) * PI * 2);
      rotateZ(noise(index, 20) * PI * 2);
      //float input = noise(c, noise(sin(s)) * noise(cos(t)) * 0.1) * 5;
      float input = noise(c, (_a * noise(sin(s)) +
                              _b * noise(cos(t)) +
                              _c * noise(cos(t) + sin(t)) +
                              _d * noise(sin(s)) * noise(cos(t))
                              ) / (_a+_b+_c+_d) * 0.1
                          ) * 5;
      //input = noise(c, noise(sin(s)) * noise(cos(t)) * noise(cos(s * t)) * 0.1) * 50;
      fill(input * 2550 % 255, 255, 255);
      box(20);
      popMatrix();
    }
  }
  popMatrix();
}

void mouseClicked() {
  reset();
}

void reset()
{
  seed = random(100);
  frameCount = 0;
}
