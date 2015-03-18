int tileSize = 42;
float chance = 0.5;

PShape[][] modules;
boolean[][] tiles;
int tileCountX;
int tileCountY;
int baseX;
int baseY;

void setup()
{
  size(500, 500);
  colorMode(HSB, 255);
  smooth();
  
  noiseSeed((int) random(100000));
  
  if (modules == null)
  {
    modules = new PShape[3][16];
    for (int n = 0; n < 3; n++)
    {
      for (int i = 0; i < 16; i++)
      {
        String filename = nf(i, 2) + "_" + n + ".svg";
        if (new File(dataPath(filename)).exists())
        {
          modules[n][i] = loadShape(filename);
        }
      }
    }
  }
  
  tileCountX = floor(width / tileSize);
  tileCountY = floor(height / tileSize);
  
  baseX = width % tileSize / 2;
  baseY = height % tileSize / 2;
  
  tiles = new boolean[tileCountX][tileCountY];
  
  for (int x = 0; x < tileCountX; x++)
  {
    for (int y = 0; y < tileCountY; y++)
    {
      tiles[x][y] = noise(x, y) <= chance;
    }
  }
  
  execute();
}

void draw()
{
}

void mouseClicked()
{
  setup();
}

void execute()
{
  background(255);
  
  for (int x = 0; x < tileCountX; x++)
  {
    for (int y = 0; y < tileCountY; y++)
    {
      if (!tiles[x][y])
        continue;
        
      int value = 0;
      if (IsSet(x + 1, y)) value += 1;
      if (IsSet(x, y + 1)) value += 2;
      if (IsSet(x - 1, y)) value += 4;
      if (IsSet(x, y - 1)) value += 8;
      
      PShape module = null;
      while (module == null)
      {
        int i = (int)random(3);
        module = modules[i][value];
      }
      
      //module.disableStyle();
      //fill(noise(x * 0.1, y * 0.1) * 255, 255, 255);
      
      shape(module,
            baseX + x * tileSize,
            baseY + y * tileSize,
            tileSize, tileSize);
    }
  }
}

boolean IsSet(int x, int y)
{
  if ((x < 0) || (y < 0) || (x >= tileCountX) || (y >= tileCountY))
    return false;
    
  return tiles[x][y];
}
