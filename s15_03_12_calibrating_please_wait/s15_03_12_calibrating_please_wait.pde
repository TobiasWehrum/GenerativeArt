int stepDistance = 10;
int lineLength = 44;
int seed = 0;
float speed = 3;
float animationStatus;
int mode = 1;
float scale = 1;

void scaledSize(int originalWidth, int originalHeight, int desiredWidth, int desiredHeight, String mode)
{
  size(desiredWidth, desiredHeight, mode);
  scale = min((float)desiredWidth / originalWidth, (float)desiredHeight / originalHeight);
}

void setup()
{
  //scaledSize(500, 500, 1000, 1000, OPENGL);
  size(500, 500, OPENGL);
  blendMode(ADD);

  seed = (int) random(100000);
  randomSeed(seed);
  noiseSeed(seed);
  
  animationStatus = 0;
}

void draw()
{
  randomSeed(seed);
  
  background(0);
  strokeCap(PROJECT);
  strokeWeight(10);
  stroke(255, 40);
  
  animationStatus += 0.001 * speed;
  
  int currentStepDistance = (int)(stepDistance * scale);
  for (int x = currentStepDistance / 2; x < width; x += currentStepDistance)
  {
    for (int y = currentStepDistance / 2; y < height; y += currentStepDistance)
    {
      //int i = x * x + y * y;
      PVector deltaFromCenter = new PVector(x - width / 2.0, y - height / 2.0);
      float distanceFromCenter = deltaFromCenter.mag();
      float angleFromCenter = atan2(deltaFromCenter.y, deltaFromCenter.x);
      float angle = noise(distanceFromCenter * 0.01, animationStatus) * PI * 2 * 10;
      float length = noise(distanceFromCenter * 0.01, 10 + animationStatus) * lineLength * scale;
      float c = noise(distanceFromCenter * 0.01, 20 + animationStatus) * 255;
      float strokeWeight = noise(distanceFromCenter * 0.01, 20 + animationStatus) * 20 * scale;
      
      if (mode == 0)
      {
        noStroke();
        fill(c, 50);
      }
      else
      {
        strokeWeight(strokeWeight);
        stroke(c, 50);
      }
      
      angle += angleFromCenter;
      float dx = cos(angle);
      float dy = sin(angle);
      float sx = x;
      float sy = y;
      
      //float sAngle = angleFromCenter + noise(distanceFromCenter * 0.01, animationStatus * 0.1) * PI * 2 * 10;
      //sx = width / 2.0 + cos(sAngle) * distanceFromCenter;
      //sy = height / 2.0 + sin(sAngle) * distanceFromCenter;
      
      //float newDistanceFromCenter = distanceFromCenter + noise(distanceFromCenter * 0.01, animationStatus * 10) * 100;
      //sx = width / 2.0 + deltaFromCenter.x / distanceFromCenter * newDistanceFromCenter;
      //sy = height / 2.0 + deltaFromCenter.y / distanceFromCenter * newDistanceFromCenter;
      
      if (mode == 0)
      {
        pushMatrix();
        translate(sx - length / 2, sy - length / 2);
        rotate(angle);
        rect(0, 0, length, length);
        popMatrix();
      }
      else
      {
        line(sx, sy, sx + dx * length, sy + dy * length);
      }
    }
  }
}

void mouseWheel(MouseEvent event) {
  speed = max(speed - event.getCount(), 1);
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
  
  if (key == ' ')
  {
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
    //mode = (mode + 1) % 2;
  }
}
