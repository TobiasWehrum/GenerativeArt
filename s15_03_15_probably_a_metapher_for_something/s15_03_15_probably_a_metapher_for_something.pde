/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.
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

  sphereDetail(8);
  
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
  
  /*
  pushMatrix();
  fill(0, 10);
  noStroke();
  translate(0, 0, 0);
  rect(0, 0, width, height);
  popMatrix();
  */
  
  background(0);

  directionalLight(255, 0, 255, 0, 0, -1);
  //lights();
  
  pushMatrix();
  //translate(100, 100, 0);
  translate(width / 2, height / 2, -150);
  //lights();
  //rotateY(frameCount * 0.01 + seed);
  //rotateZ(seed);
  //rotateX(frameCount * 0.04);
  float ri = frameCount * 0.003;
  //rotateX(noise(ri, 0) * PI * 2); 
  //rotateY(noise(ri, 10) * PI * 2 + frameCount * 0.02);
  //rotateZ(noise(ri, 20) * PI * 2);

  int count = 150;
  float distance = 350;
  float radius = 10;

  float baseIndex = frameCount * 0.004;

  //stroke(0, 255, 255);
  //fill(0, 255, 255);

  for (int i = 0; i < count; i++)
  {
    float s = (noise(i, 10, baseIndex) * PI * 2);
    float t = (noise(i, 20, baseIndex) * PI * 2) + PI;
    
    float x = cos(s) * sin(t);
    float y = sin(s) * sin(t);
    float z = cos(t);
    float r = distance * noise(i, 30, baseIndex);
    
    float a = ((z * r) + distance) / 2 / distance;
    noStroke();
    fill((lerp(0, 255, a) + 70) % 255, 255, lerp(-255, 300, a));
    
    pushMatrix();
    translate(x * r, y * r, z * r);
    sphere(radius);
    popMatrix();
    
    stroke(0, 0, lerp(-255, 255, a));
    line(0, 0, 0, x * r, y * r, z * r);
  }

  //noStroke();
  //fill(255, 255, 255, 100);
  //sphere(distance);

  popMatrix();

/*
  hint(DISABLE_DEPTH_TEST);
  hint(DISABLE_DEPTH_SORT);
  
  pushMatrix();
  fill(0, 50);
  noStroke();
  translate(0, 0, 0);
  rect(0, 0, width, height);
  popMatrix();
  
  hint(ENABLE_DEPTH_TEST);
  hint(ENABLE_DEPTH_SORT);
  */
}

void reset()
{
  seed = random(100);
  frameCount = 0;
}
