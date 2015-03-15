float radiusMin = 10;
float radiusMax = 30;
float speedMin = 0.2;
float speedMax = 2;
int circleCountMin = 20;
int circleCountMax = 40;

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
  
  background(255);
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
      b = 0;
      break;
      
    case 1:
      h = 0;
      s = 0;
      b = r;
      break;
      
    default:
      h = r;
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
        ellipse(centerX, centerY, size, size);
      }
    }
  }
}

void keyPressed()
{
  if (key == '+')
  {
    speed++;
  }
  else if (key == '-')
  {
    if (speed > 1)
      speed--;
  }
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
    mode = (mode + 1) % 3;
    circles.clear();
    setup();
  }
}
