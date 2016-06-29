color[] loadGradient(String filename)
{
  return loadGradient(filename, false);
}

color[] loadGradient(String filename, boolean reverse)
{
  PImage gradientImage = loadImage(filename);
  color[] gradient = new color[gradientImage.width];
  for (int i = 0; i < gradientImage.width; i++)
  {
    gradient[i] = gradientImage.get(reverse ? (gradientImage.width - i - 1) : i, 0);
  }
  return gradient;
}

color getColor(color[] gradient, float percent)
{
  return gradient[min((int)(gradient.length * percent), gradient.length-1)];
}