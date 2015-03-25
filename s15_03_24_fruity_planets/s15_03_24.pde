/*
Copyright (c) 2015 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
*/

ArrayList<PImage> backgrounds;
ArrayList<PImage> animals;
ArrayList<PImage> city;
ArrayList<PImage> fruits;
ArrayList<PImage> misc;
ArrayList<PImage> trees;

void setup()
{
  //size(1000, 1000);
  size(displayWidth, displayHeight);
  colorMode(HSB, 255);
  
  backgrounds = loadImages("backgrounds");
  animals = loadImages("animals");
  city = loadImages("city");
  fruits = loadImages("fruits");
  misc = loadImages("misc");
  trees = loadImages("trees");
  
  refresh();
}

void refresh()
{
  noiseSeed((int) random(100000));
  
  drawBackground();
  drawImage();
}

void drawBackground()
{
  PImage background = backgrounds.get((int)random(backgrounds.size()));
  for (int x = 0; x < width; x += background.width)
  {
    for (int y = 0; y < height; y+= background.height)
    {
      image(background, x, y);
    }
  }
}

void drawImage()
{
  pushMatrix();
  translate(width / 2, height / 2);
  float radius = min(width, height) / 4;
  float objectRadiusA = radius * 0.9;
  float objectRadiusB = radius * 0.7;
  //tint(0, 0, 150);
  drawRandomImage(fruits, 0, 0, random(0, TWO_PI), 0.5, 0.5, radius*2);
  
  drawImages(city, 3, 10, objectRadiusA, objectRadiusB, 0, TWO_PI, radius * 0.8, radius * 1.4, 150);
  drawImages(trees, 3, 8, objectRadiusA, objectRadiusB, 0, TWO_PI, radius * 0.8, radius * 1.2, 200);
  drawImages(misc, 0, 1, objectRadiusA, objectRadiusB, 0, TWO_PI, radius * 0.6, radius * 0.8, 150);
  drawImages(animals, 4, 7, objectRadiusA * 0.7, objectRadiusB, 0, TWO_PI, radius * 0.4, radius * 0.6, 255);
  
  popMatrix();
}

void drawImages(ArrayList<PImage> images, int minCount, int maxCount, float minRadius, float maxRadius,
                float minAngle, float maxAngle, float minHeight, float maxHeight, float brightness)
{
  //tint(0, 0, brightness);
  int count = (int)random(minCount, maxCount + 1);
  for (int i = 0; i < count; i++)
  {
    float angle = random(minAngle, maxAngle);
    float lookAngle = angle;
    float distance = random(minRadius, maxRadius);
    float x = cos(angle) * distance;
    float y = sin(angle) * distance;
    float drawHeight = random(minHeight, maxHeight);
    drawRandomImage(images, x, y, lookAngle, 0.5, 1, drawHeight);
  }
}

void drawRandomImage(ArrayList<PImage> images, float x, float y, float angle, float anchorX, float anchorY, float drawHeight)
{
  angle += PI / 2;
  
  PImage image = images.get((int)random(images.size()));
  float scale = drawHeight / image.height;
  
  pushMatrix();
  translate(x, y);
  rotate(angle);
  translate(-image.width * scale * anchorX, -image.height * scale * anchorY);
  scale(scale);
  image(image, 0, 0);
  popMatrix();
}

ArrayList<PImage> loadImages(String directoryName)
{
  ArrayList<PImage> images = new ArrayList<PImage>();
  for (int i = 1; i < 99; i++)
  {
    String filename = directoryName + "\\" + nf(i, 2) + ".png";
    if (!new File(dataPath(filename)).exists())
      break;
    
    images.add(loadImage(filename));
  }
  
  return images;
}

void draw()
{
}

void mouseClicked()
{
  refresh();
}
