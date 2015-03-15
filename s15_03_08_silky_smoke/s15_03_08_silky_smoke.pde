/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to switch between white/color modes.
- +/- keys or mouse wheel to change hue.
*/

float radiusMin = 10;
float radiusMax = 30;
float speedMin = 0.2;
float speedMax = 2;
int circleCountMin = 200;
int circleCountMax = 400;
float alpha = 5;
float hue = 0;

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
    radius = random(radiusMin, radiusMax);
    
    float angle = random(PI * 2);
    float speed = random(speedMin, speedMax);
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

ArrayList<Circle> circles = new ArrayList<Circle>();

int mode = 0;
int speed = 1;

void setup()
{
  size(500, 500, OPENGL);
  colorMode(HSB, 255);
  
  int circleCount = (int)random(circleCountMin, circleCountMax);
  for (int i = 0; i < circleCount; i++)
  {
    circles.add(new Circle());
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
  
  for (Circle circle : circles)
  {
    circle.update();
    //circle.draw();
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
  
  for (Circle circle1 : circles)
  {
    for (Circle circle2 : circles)
    {
      if (circle1 == circle2)
        continue;
      
      float distance = dist(circle1.x, circle1.y, circle2.x, circle2.y);
      if (distance <= circle1.radius + circle2.radius)
      {
        float centerX = (circle1.x + circle2.x) / 2;
        float centerY = (circle1.y + circle2.y) / 2;
        float size = distance;
        //ellipse(centerX, centerY, size, size);
        
        //stroke((h + 255 + lerp(-25, 25, noise(centerX, centerY))) % 255, s, b, 10);
        
        triangle(circle1.x, circle1.y, circle2.x, circle2.y, centerX, centerY);
        //line(circle1.x, circle1.y, circle2.x, circle2.y);
      }
    }
  }
}

void keyPressed()
{
  if (key == '+')
  {
    hue = (hue + 1) % 255;
  }
  else if (key == '-')
  {
    hue = (255 + hue - 1) % 255;
  }
}

void mouseWheel(MouseEvent event) {
  hue = (hue + 255 + event.getCount()) % 255;
  mode = 1;
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    circles.clear();
    setup();
  }
  else if (mouseButton == RIGHT)
  {
    mode = (mode + 1) % 2;
  }
}
