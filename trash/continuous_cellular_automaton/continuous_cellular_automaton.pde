Cell[][] currentCells;
Cell[][] previousCells;
int cellCountX = 60;
int cellCountY = 60;
int cellWidth;
int cellHeight;

void setup()
{
  //size(displayWidth, displayHeight);
  size(600, 600);
  //fullScreen();
  
  //colorMode(HSB, 360, 255, 255, 255);
  //blendMode(ADD);
  
  prepare();
  
  //frameRate(30);
  frameRate(1);
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
      currentCells[x][y] = new Cell(posX, posY);
      previousCells[x][y] = new Cell(posX, posY);
      
      currentCells[x][y].life = (random(0, 1) < 0.9) ? 0 : 1;
    }
  }
  
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
      currentCells[x][y].life = min(1, max(0, previousCells[x][y].life + getNewLife(x, y)));
    }
  }
}

float getNewLife(int cellX, int cellY)
{
  float neighborLife = 0;
  for (int xOffset = -1; xOffset <= 1; xOffset++)
  {
    int neighborX = (cellX + xOffset + cellCountX) % cellCountX;
    for (int yOffset = -1; yOffset <= 1; yOffset++)
    {
      int neighborY = (cellY + yOffset + cellCountY) % cellCountY;
      if ((xOffset == 0) && (yOffset == 0))
        continue;
      
      neighborLife += previousCells[neighborX][neighborY].life;
    }
  }
  
  if (previousCells[cellX][cellY].life > 0.5)
  {
    if ((neighborLife >= 2) && (neighborLife <= 3))
      return neighborLife / 9;
  }
  else
  {
    return neighborLife / 9;
  }
  
  return -0.4f;
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
  float life;
  int posX;
  int posY;
  
  Cell(int posX, int posY)
  {
    this.posX = posX;
    this.posY = posY;
  }
  
  void draw()
  {
    //int steps = 2;
    //fill(255, ((float)floor(life * steps) / steps) * 255);
    fill(255, life * 255);
    rect(posX, posY, cellWidth, cellHeight);
  }
}