/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to pause/resume.
- "m" to change blending mode (Lightweaver [default] or SilkWeaver)
*/

float radiusMin = 10;
float radiusMax = 30;
float speedMin = 0.2;
float speedMax = 2;
int circleCountMin = 200;
int circleCountMax = 400;
int markCountMin = 5;
int markCountMax = 10;
float alpha = 0;
float hue = 0;
int currentBlendMode = ADD;

float scale = 1;

class Circle
{
  float x;
  float y;
  float radius;
  float dx;
  float dy;
  
  Circle()
  {
    x = random(width);
    y = random(height);
    radius = random(radiusMin, radiusMax) * scale;
    
    float angle = random(PI * 2);
    float speed = random(speedMin, speedMax) * scale;
    dx = cos(angle) * speed;
    dy = sin(angle) * speed;
  }
  
  void update()
  {
    x += dx;
    y += dy;
    
    if (x <= 0)
    {
      x = 0;
      dx *= -1;
    }

    if (x > width)
    {
      x = width;
      dx *= -1;
    }
    
    if (y <= 0)
    {
      y = 0;
      dy *= -1;
    }

    if (y > height)
    {
      y = height;
      dy *= -1;
    }
  }
  
  void draw()
  {
    stroke(255);
    noFill();
    ellipse(x, y, radius * 2, radius * 2);
  }
}

class Mark
{
  float x;
  float y;
  float radius;
  float dx;
  float dy;
  
  
  color c;
  int index;
  
  Mark(int index, color c)
  {
    this.c = c;
    this.index = index;

    x = random(width);
    y = random(height);
    radius = random(30, 150) * scale;
    
    r();
  }
  
  void update()
  {
    float speedModA = lerp(0.1, 2, noise(0, index, frameCount * 0.1)) * scale;
    float speedModB = lerp(0.1, 2, noise(10, index, frameCount * 0.1)) * scale;
    
    x += dx * speedModA;
    y += dy * speedModB;
    
    if (x <= 0)
    {
      x = 0;
      dx *= -1;
      r();
    }

    if (x > width)
    {
      x = width;
      dx *= -1;
      r();
    }
    
    if (y <= 0)
    {
      y = 0;
      dy *= -1;
      r();
    }

    if (y > height)
    {
      y = height;
      dy *= -1;
      r();
    }
  }
  
  void r()
  {
    float angle = random(PI * 2);
    float speed = random(speedMin, speedMax) * 2 * scale;
    dx = cos(angle) * speed;
    dy = sin(angle) * speed;
  }
  
  void draw()
  {
    stroke(255);
    noFill();
    ellipse(x, y, radius * 2, radius * 2);
  }
}

ArrayList<Circle> circles = new ArrayList<Circle>();
ArrayList<Mark> marks = new ArrayList<Mark>();

int mode = 0;
int speed = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight, String mode)
{
  size(desiredWidth, desiredHeight, mode);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  scaledSize(500, 500, 1000, 1000, OPENGL);
  colorMode(HSB, 255);
  blendMode(currentBlendMode);
  
  circles.clear();
  marks.clear();
  frameCount = 0;
  speed = 1;
  
  int circleCount = (int)random(circleCountMin, circleCountMax);
  for (int i = 0; i < circleCount; i++)
  {
    circles.add(new Circle());
  }
  
  int markCount = (int)random(markCountMin, markCountMax);
  float hueBase = random(255);
  for (int i = 0; i < markCount; i++)
  {
    //float hue = (hueBase + ((float)i/markCount) * 255) % 255;
    float h = (255 + hueBase + random(-10, 10)) % 255;
    float s = random(150, 255);
    float b = random(150, 255);
    color c = color(h, s, b, 5);
    marks.add(new Mark(i, c));
  }
  
  background(0);
  stroke(0, 0, 0, 10);
  noFill();
}

void draw()
{
  //background(0);
  
  for (int i = 0; i < speed; i++)
  {
    step();
  }
}

void step()
{
  fill(0, alpha);
  noStroke();
  rect(0,0,width,height);
  //strokeWeight(scale);
  
  for (Circle circle : circles)
  {
    circle.update();
    //circle.draw();
  }
  
  for (Mark mark : marks)
  {
    mark.update();
    //mark.draw();
  }
  
  float r = (noise(frameCount * speed * 0.00004) * 255 * 10) % 255;
  float h, s, b;
  switch (mode)
  {
    case 0:
      h = 0;
      s = 0;
      b = 255;
      break;
      
    default:
      h = hue;
      s = 255;
      b = 255;
      break;
  }

  stroke(h, s, b, 10);
  //fill(h, s, b, 10);
  
  for (Mark mark : marks)
  {
    //stroke(mark.hue, 255, 255, 10);
    stroke(mark.c);
      
    for (Circle circle2 : circles)
    {
      //if (circle1 == circle2)
      //  continue;
      
      float distance = dist(mark.x, mark.y, circle2.x, circle2.y);
      if (distance <= mark.radius + circle2.radius)
      {
        float centerX = (mark.x + circle2.x) / 2;
        float centerY = (mark.y + circle2.y) / 2;
        float size = distance;
        //ellipse(centerX, centerY, size, size);
        
        //stroke((h + 255 + lerp(-25, 25, noise(centerX, centerY))) % 255, s, b, 10);
        
        //triangle(mark.x, mark.y, circle2.x, circle2.y, centerX, centerY);
        line(centerX, centerY, circle2.x, circle2.y);
      }
    }
  }
}

void keyPressed()
{
  if (key == 'm')
  {
    if (currentBlendMode == ADD)
    {
      currentBlendMode = BLEND;
    }
    else
    {
      currentBlendMode = ADD;
    }
    setup();
  }
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    setup();
  }
  else if (mouseButton == RIGHT)
  {
    speed = 1 - speed;
  }
}
