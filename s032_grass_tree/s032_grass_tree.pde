/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Right-click to instantly finish growing.
*/

ArrayList<Branch> branchList = new ArrayList<Branch>();
ArrayList<Branch> newBranchList = new ArrayList<Branch>();

void setup()
{
  size(1024, 768);
  colorMode(HSB, 360, 100, 100, 100);
  reset();
}

void mousePressed()
{
  reset();
  if (mouseButton == RIGHT)
  {
    while (update())
    {
    }
  }
}

void reset()
{
  background(0, 0, 0);
  branchList.clear();
  
  int count = (int) random(5, 10);
  
  for (int i = 0; i < count; i++)
  {
    branchList.add(new Branch(((float)(1 + i)/(count+1)) * width, height + 10, 10, -PI*0.5, random(0.01, 0.02),
                              color(0, 0, 50, 0), random(30, 150)));
  }
}

void draw()
{
  update();
}

boolean update()
{
  for (Branch branch : branchList)
  {
    branch.update();
  }
  
  for (Branch branch : newBranchList)
  {
    branchList.add(branch);
  }
  newBranchList.clear();
  
  for (Branch branch : branchList)
  {
    if (branch.size > 0)
      return true;
  }
  
  return false;
}

class Branch
{
  float x;
  float y;
  float size;
  float angle;
  float offset;
  float decay;
  float speed;
  float branchChance;
  color c;
  float leafHue;
  float hueChange;
  
  Branch(float x, float y, float size, float angle, float branchChance, color c, float leafHue)
  {
    this.x = x;
    this.y = y;
    this.size = size;
    this.angle = angle;
    
    offset = random(1000000);
    
    decay = random(0.02, 0.05);
    
    hueChange = random(-0.25, 0.25);
    
    speed = random(0.5, 2);
    
    this.branchChance = branchChance;
    this.c = c;
    this.leafHue = leafHue;
  }
  
  void update()
  {
    if (size <= 0)
      return;
    
    noStroke();
    fill(c);
    
    ellipse(x, y, size, size);
    
    size -= decay;
    
    angle += (noise(frameCount * 0.01, offset) * 2 - 1) * 0.05;
    
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    
    leafHue += hueChange;
    
    if (random(1) < branchChance)
    {
      newBranchList.add(new Branch(x, y, size, angle, branchChance / 2, c, leafHue));
    }

    if (random(1) < branchChance * 10)
    {
      newBranchList.add(new Branch(x, y, 1, angle, branchChance / 2, color(leafHue, 100, random(50, 100), 100), leafHue));
    }
  }
}