Circle circle;
PVector previousPosition;
int lineCount;
int lineStepCount;
int lineCurrentStep;

void setup()
{
  size(768, 768, P2D);
  reset();
}

void mouseClicked()
{
  reset();
}

void reset()
{
  circle = new Circle();
  previousPosition = circle.getCurrentPosition();

  lineCount = 30;
  lineStepCount = width;
  
  float lineOffset = height / lineCount;

  background(0);
  stroke(255, 255, 255, 255);
  fill(255);
  drawCircle();

  loadPixels();
  
  noFill();
  stroke(0, 0, 255, 255);
  for (int i = 0; i < lineCount; i++)
  {
    float lineNoiseOffset = 0;
    beginShape();
    for (lineCurrentStep = 0; lineCurrentStep < lineStepCount; lineCurrentStep++)
    {
      float x = ((float)lineCurrentStep / (lineStepCount - 1)) * width;
      float y = ((float)(i + 1) / (lineCount + 1)) * height;
      boolean isCircle = pixels[(int)x + (int)y * width] == color(255, 255, 255, 255);
      
      float multiplier = isCircle ? 1 : 0.5;
      if (isCircle)
        stroke(255, 0, 0);
      else
        stroke(0, 0, 255);
      y += (noise(i * 13.5, lineNoiseOffset) * lineOffset * 2 - lineOffset) * multiplier;
      
      vertex(x, y);
      
      lineNoiseOffset += isCircle ? 0.1 : 0.01;
    }
    endShape();
  }
}

void draw()
{
}

void drawCircle()
{
  circle.reset();
  beginShape();
  for (int i = 0; i < circle.stepCount; i++)
  {
    //if (circle.currentStep == circle.stepCount)
    //  return;
    
    PVector position = circle.getCurrentPosition();
    vertex(position.x, position.y);
    //previousPosition = position;
    circle.advance();
  }
  endShape(CLOSE);
}

class Circle
{
  float x;
  float y;
  float radiusMin;
  float radiusAdd;
  float angle;
  int stepCount;
  int currentStep;
  float noiseOffset;
  float noiseScale;
  float startRadius;
  float startAngle;
  
  Circle()
  {
    x = width / 2;
    y = height / 2;
    radiusMin = random(10, 100);
    radiusAdd = random(200, min(width, height) / 2 - radiusMin);
    stepCount = (int)random(100, 1000);//random(10, 1000);
    noiseOffset = random(0, 1000000);
    noiseScale = random(0.01, 0.1);
    startAngle = random(0, PI * 2);
    angle = startAngle;
    reset();
  }
  
  void reset()
  {
    currentStep = 0;
    startRadius = -1;
  }
  
  void advance()
  {
    angle = startAngle + ((float)currentStep / stepCount) * PI * 2;
    currentStep++;
  }
  
  PVector getCurrentPosition()
  {
    float currentRadius = radiusMin + noise(noiseOffset + currentStep * noiseScale, frameCount * 0.01) * radiusAdd; 
    if (startRadius == -1)
    {
      startRadius = currentRadius;
    }
    else
    {
      float percent = (float)currentStep / stepCount;
      if (percent > 0.9)
      {
        percent = map(percent, 0.9, 1, 0, 1);
        currentRadius = lerp(currentRadius, startRadius, percent);
      }
      
      /*
      if (currentStep % stepCount == 0)
      {
        currentRadius = startRadius;
      }
      */
    }
    return new PVector(x + cos(angle) * currentRadius, y + sin(angle) * currentRadius);
  }
}