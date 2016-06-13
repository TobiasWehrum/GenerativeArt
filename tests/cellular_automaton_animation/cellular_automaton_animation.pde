Cell[][] currentCells;
Cell[][] previousCells;
int cellCountX = 60;
int cellCountY = 60;
int cellWidth;
int cellHeight;

int computationFrames = 15;

void setup()
{
  //size(displayWidth, displayHeight);
  size(600, 600);
  //fullScreen();
  
  //colorMode(HSB, 360, 255, 255, 255);
  //blendMode(ADD);
  
  prepare();
  
  //frameRate(30);
  //frameRate(10);
  frameRate(30);
}

void prepare()
{
  currentCells = new Cell[cellCountX][cellCountY];
  previousCells = new Cell[cellCountX][cellCountY];
  int extents = min(width, height);
  cellWidth = extents / cellCountX;
  cellHeight = extents / cellCountY;
  int cellStartX = (width - cellCountX * cellWidth) / 2;
  int cellStartY = (height - cellCountY * cellHeight) / 2;
  for (int x = 0; x < cellCountX; x++)
  {
    for (int y = 0; y < cellCountY; y++)
    {
      int posX = cellStartX + cellWidth * x;
      int posY = cellStartY + cellHeight * y;
      boolean alive = random(0, 1) < 0.3;
      
      currentCells[x][y] = new Cell(posX, posY, alive);
      previousCells[x][y] = new Cell(posX, posY, alive);
    }
  }
  
  computeNextCellStep();
  
  background(50);
  fill(0, 50);
  noStroke();
  for (int i = 0; i < 10; i++)
    rect(0, 0, width, height);
}

void draw()
{
  resetBackground();
  
  noStroke();
  fill(255);
  
  noStroke();
  for (int x = 0; x < cellCountX; x++)
  {
    for (int y = 0; y < cellCountY; y++)
    {
      currentCells[x][y].draw();
    }
  }
  
  if ((frameCount % computationFrames) == 0)
    computeNextCellStep();
  
  //debugDrawChannelPitch();
  //debugDrawChannelInstruments();
}

void computeNextCellStep()
{
  Cell[][] temp = currentCells;
  currentCells = previousCells;
  previousCells = temp;
  
  for (int x = 0; x < cellCountX; x++)
  {
    for (int y = 0; y < cellCountY; y++)
    {
      currentCells[x][y].alive = getNewLife(x, y);
      currentCells[x][y].size = previousCells[x][y].size;
      currentCells[x][y].targetSize = currentCells[x][y].alive ? 1f : 0f;
    }
  }
}

boolean getNewLife(int cellX, int cellY)
{
  int neighborLife = 0;
  for (int xOffset = -1; xOffset <= 1; xOffset++)
  {
    int neighborX = (cellX + xOffset + cellCountX) % cellCountX;
    for (int yOffset = -1; yOffset <= 1; yOffset++)
    {
      int neighborY = (cellY + yOffset + cellCountY) % cellCountY;
      if ((xOffset == 0) && (yOffset == 0))
        continue;
      
      if (previousCells[neighborX][neighborY].alive)
        neighborLife++;
    }
  }
  
  if (previousCells[cellX][cellY].alive)
  {
    switch (neighborLife)
    {
      case 2:
      case 3:
      //case 4:
      //case 6:
      //case 7:
      //case 8:
        return true;
    }
  }
  else
  {
    switch (neighborLife)
    {
      //case 1:
      case 3:
      //case 6:
      //case 7:
      //case 8:
        return true;
    }
  }
  
  return false;
}

void resetBackground()
{
  //fill(0, 50);
  //noStroke();
  //rect(0, 0, width, height);
  background(0);
}

class Cell
{
  float colorPercent;
  boolean alive;
  int posX;
  int posY;
  
  float size;
  float targetSize;
  
  Cell(int posX, int posY, boolean alive)
  {
    this.posX = posX;
    this.posY = posY;
    this.alive = alive;
    
    size = alive ? 1f : 0f;
    targetSize = size;
  }
  
  void draw()
  {
    size = lerp(size, targetSize, 0.25f);
    
    fill(255, 255);
    rect(posX + (cellWidth/2) * (1 - size), posY + (cellHeight/2) * (1 - size), cellWidth * size, cellHeight * size);
  }
}