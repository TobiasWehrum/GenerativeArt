/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Space to show UI.
*/

import controlP5.*;

class Circle
{
  float generation;
  float radius;
  float angle;
  PVector position;
  
  Circle(PVector position, float angle, float radius, float generation)
  {
    this.position = position;
    this.angle = angle;
    this.radius = radius;
    this.generation = generation;
  }
}

int circleCount = 20;

ArrayList<Circle> circles = new ArrayList<Circle>();
ArrayList<Circle> possibleCircles = new ArrayList<Circle>();
float fullAngle = PI * 2; 
float angleDelta = fullAngle / 3f;
float radius = 35;
float variation = radians(100);
int seed;
float saturation;
float brightness;
boolean showing;

ControlP5 cp5;

void setup()
{
  size(500, 500);
  colorMode(HSB, 255);
  frameRate(45);
  
  cp5 = new ControlP5(this);
  
  PFont font = createFont("arial", 12);
  
  cp5.addTextfield("randomseed")
     .setPosition(2, 1)
     .setSize(40, 20)
     .setAutoClear(false)
     .hide()
     .getCaptionLabel().hide()
     ;

  cp5.addBang("randomize")
     .setPosition(44, 1)
     .setSize(80, 20)
     .hide()
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
     
  
  randomSeed();
}

public void randomize()
{
  randomSeed();
}

void randomSeed()
{
  seed = int(random(9999));
  cp5.get(Textfield.class, "randomseed").setValue("" + seed);
  frameCount = 0;
  background(0);
}

void mouseClicked()
{
  if (!showing)
  {
    randomSeed();
  }
}

void keyPressed()
{
  if (key == ' ')
  {
    if (showing)
    {
      cp5.get("randomseed").hide();
      cp5.get("randomize").hide();
    }
    else
    {
      cp5.get("randomseed").show();
      cp5.get("randomize").show();
    }
    showing = !showing; 
  }
}

void draw()
{
  String text = cp5.get(Textfield.class, "randomseed").getText();
  if (text.length() > 0)
  {
    try {
    int newSeed = Integer.parseInt(text);
    if (newSeed != seed)
    {
      if (newSeed > 9999)
      {
        cp5.get(Textfield.class, "randomseed").setText("" + seed);
      }
      else
      {
        seed = newSeed;
        frameCount = 0;
        background(0);
      }
    }
    } catch (Exception e)
    {
      cp5.get(Textfield.class, "randomseed").setText("" + seed);
    }
  }
  
  randomSeed(seed);
  noiseSeed((int)random(seed));
  
  float rotationSpeed = (round(random(0, 1)) == 0 ? -1 : 1) * random(0.01, 0.02);
  rotationSpeed = 0;
  
  //saturation = random(200, 255);
  //brightness = random(200, 255);
  saturation = 255;
  brightness = 255;
  
  circles.clear();
  possibleCircles.clear();
  
  fill(0, 75);
  rect(0,0,width,height);
  //background(0);
  
  translate(width / 2f, height / 2f);
  rotate(frameCount * rotationSpeed);
  translate(-width / 2f, -height / 2f);
  
  stroke(255);
  
  DrawTriangleInCircle(new Circle(new PVector(250, 250), RandomVariation(),
                                  RandomRadius(30), 0));
  while ((circles.size() < circleCount) && (possibleCircles.size() > 0))
  {
    int index = int(random(0, possibleCircles.size()));
    Circle circle = possibleCircles.get(index);
    possibleCircles.remove(index);
    
    float x = circle.position.x;
    float y = circle.position.y;
    
    //if ((x >= -radius) && (x <= width + radius) &&
    //    (y >= -radius) && (y <= height + radius))
    {
      DrawTriangleInCircle(circle);
    }
  }

  translate(width / 2f, height / 2f);
  rotate(-frameCount * rotationSpeed);
  translate(-width / 2f, -height / 2f);
}

float randomColorComponent(int i, float generation)
{
  return lerp(0, 255 * 10, noise(i * 10, generation * 0.1)) % 255;
}

PVector randomColor(float generation)
{
  return new PVector(randomColorComponent(0, generation),
                     saturation,
                     brightness);
}

void DrawTriangleInCircle(Circle circle)
{
  if (circles.size() >= circleCount)
    return;
  
  circles.add(circle);
  float angle1 = circle.angle;
  float angle2 = angle1 + angleDelta;
  float angle3 = angle2 + angleDelta;
  
  float angle = angle1;
  PVector p1 = new PVector(circle.position.x + cos(angle) * circle.radius,
                           circle.position.y + sin(angle) * circle.radius);
  angle = angle2;
  PVector p2 = new PVector(circle.position.x + cos(angle) * circle.radius,
                           circle.position.y + sin(angle) * circle.radius);
  angle = angle3;
  PVector p3 = new PVector(circle.position.x + cos(angle) * circle.radius,
                           circle.position.y + sin(angle) * circle.radius);
  
  PVector c = randomColor(circle.generation);
  
  beginShape();
  fill(c.x, c.y, c.z, 255);
  //stroke(255 - c.x, 255 - c.y, 255 - c.z, 255);
  stroke(255, 0, 255, 100);
  vertex(p1.x, p1.y);
  vertex(p2.x, p2.y);
  vertex(p3.x, p3.y);
  endShape(CLOSE);
  
  DrawInnerTriangle(1, p1, p2, p3, c);
  
  AddCircleAt(p2, angle2, RandomRadius(circle.radius), circle.generation + GenerationAdd());
  AddCircleAt(p3, angle3, RandomRadius(circle.radius), circle.generation + GenerationAdd());
}

float GenerationAdd()
{
  return random(-0.5, 0.5);
}

float RandomVariation()
{
  return noise(random(1000), frameCount * 0.01) * variation * 2 - variation;
}

float RandomRadius(float inputRadius)
{
  return lerp(inputRadius - 5, inputRadius + 5, noise(random(1000), frameCount * 0.01));
  //return inputRadius;
}

void AddCircleAt(PVector point, float angle, float radius, float generation)
{
  angle += RandomVariation();
  
  point.x += Math.cos(angle) * radius;
  point.y += Math.sin(angle) * radius;
  
  possibleCircles.add(new Circle(point, angle + PI, radius, generation));
}

void DrawInnerTriangle(int stepsLeft, PVector p1, PVector p2, PVector p3, PVector c)
{
  //c.x = 255 - c.x;
  //c.y = 255 - c.y;
  //c.z = 255 - c.z;
  
  //c.y = 255 - c.y;
  if (c.y == saturation)
  {
    c.y = 20;
  }
  else
  {
    c.y = saturation;
  }
  
  PVector newP1 = PVector.lerp(p1, p2, 0.5);
  PVector newP2 = PVector.lerp(p2, p3, 0.5);
  PVector newP3 = PVector.lerp(p3, p1, 0.5);
  
  beginShape();
  fill(c.x, c.y, c.z, 255);
  //stroke(strokeColor);
  noStroke();
  vertex(newP1.x, newP1.y);
  vertex(newP2.x, newP2.y);
  vertex(newP3.x, newP3.y);
  endShape(CLOSE);
  
  if (stepsLeft > 0)
  {
    DrawInnerTriangle(stepsLeft - 1, newP1, newP2, newP3, c);
  }
}
