int seed;

void setup()
{
  size(500, 500);
  
  seed = (int) random(100000);
  noiseSeed(seed);
}

void draw()
{
  randomSeed(seed);
  
  background(0);
  
  float centerX = width / 2;
  float centerY = height / 2;
  int circleSteps = 10;
  float circleRadius = 100;
  
  float deltaAngle = PI * 2 / circleSteps;
  float startAngle = random(0, deltaAngle);
  float previousX = 0;
  float previousY = 0;
  beginShape();
  for (int i = 0; i <= 10; i++)
  {
    float angle = startAngle + i * deltaAngle;
    float x = centerX + cos(angle) * circleRadius;
    float y = centerY + sin(angle) * circleRadius;
    
    vertex(x, y);
    
    if (i > 0)
    {
      drawTentacle((previousX + x) / 2, (previousY + y) / 2, angle, dist(x, y, previousX, previousY) / 2);
    }
    
    previousX = x;
    previousY = y;
  }
  endShape();
  
  //drawTentacle(width / 2, height, -PI/2);
}

void drawTentacle(float x, float y, float angle, float fullWidth)
{
  stroke(255);
  //stroke(120);
  fill(120);
  
  float stepPerLength = 10;
  float fullLength = 100;
  int stepCount = (int)(fullLength / stepPerLength);
  
  float deltaAngle = lerp(-PI * 2, PI * 2, (float)mouseX / width) / stepCount;
  float deltaLength = fullLength / stepCount;
  
  float previousX1 = 0;
  float previousX2 = 0;
  float previousY1 = 0;
  float previousY2 = 0;
  
  //ArrayList<PVector> points = new ArrayList<PVector>();
  for (int i = 0; i < stepCount; i++)
  {
    float t = (float)i / (stepCount - 1);
    float iT = 1 - t;
    
    float currentWidth = iT * fullWidth;
    float deltaX = cos(angle);
    float deltaY = sin(angle);
    
    float currentX1 = x + deltaY * currentWidth;
    float currentY1 = y - deltaX * currentWidth;
    float currentX2 = x - deltaY * currentWidth;
    float currentY2 = y + deltaX * currentWidth;
    
    if (i > 0)
    {
      beginShape();
      vertex(currentX1, currentY1);
      vertex(currentX2, currentY2);
      vertex(previousX2, previousY2);
      vertex(previousX1, previousY1);
      endShape(CLOSE);
    }
    
    previousX1 = currentX1;
    previousX2 = currentX2;
    previousY1 = currentY1;
    previousY2 = currentY2;
    angle += deltaAngle;
    x += deltaX * deltaLength;
    y += deltaY * deltaLength;
  }
}

class TentacleData
{
  
}
