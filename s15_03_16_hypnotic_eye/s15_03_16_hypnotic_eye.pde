/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

int seed;
float time = 0;

void setup()
{
  size(500, 500, OPENGL);
  //size(displayWidth, displayHeight, OPENGL);
  colorMode(HSB, 255);
  blendMode(ADD);
  
  time = 0;
  frameCount = 0;
  
  seed = (int)random(100000);
  noiseSeed(seed);
}

void draw()
{
  randomSeed(seed);
  
  translate(width / 2, height / 2);
  
  background(0);
  
  noFill();
  stroke(120);
  strokeWeight(4);
  
  float endLength = dist(0, 0, width / 2, height / 2);
  //float stepCount = 20;
  //float stepDelta = endLength / stepCount;
  float stepDelta = 50;//55;
  float stepCount = ceil(endLength / stepDelta);
  
  float angleOffset = log(1 + frameCount * 0.0001) * 30;
  
  time += 0.01 / angleOffset;
  
  //float maxOffset = endLength * log(1 + frameCount * 0.001) * 0.05;
  
  //float offsetX = lerp(-maxOffset, maxOffset, noise(10, time));
  //float offsetY = lerp(-maxOffset, maxOffset, noise(20, time));
  
  int count = 80;
  float delta = 2 * PI / count;
  for (int i = 0; i < count; i++)
  {
    float baseAngle = i * delta;
    
    //stroke(noise(i % 5) * 255, 30);
    
    beginShape();
    for (int step = 0; step <= stepCount; step++)
    {
      float t = (float) step / stepCount;
      //float oT = 0.8 + (1 - t) * 0.2;
      float oT = 1;
      
      stroke(0, 0, 255 * pow(t, 3), 175); //100
      
      float length = step * stepDelta;
      float angle = baseAngle + lerp(-angleOffset, angleOffset,
                                     noise(i % 2, length * 0.1, time));
      float x = cos(angle) * length;
      float y = sin(angle) * length;
      vertex(x, y * oT);
    }
    endShape();
  }
}

void mouseClicked()
{
  setup();
}
