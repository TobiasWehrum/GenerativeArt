boolean pause;
int steps = 300;

int[] variationIndex = new int[8];
int variationCount = 5;
int[][] density;
int maxDensity;

PVector position = new PVector();
PVector out = new PVector();
PVector drawPosition = new PVector();
Function finalTransform = null;

float log10;
ArrayList<Float> log10table = new ArrayList<Float>();
ArrayList<Integer> pow10table = new ArrayList<Integer>();

ArrayList<Function> functions = new ArrayList<Function>();

void setup()
{
  size(768, 768, P2D);
  blendMode(ADD);
  //colorMode(HSB, 360, 100, 100, 255);

  log10 = log(10);
  
  int power = ceil(getLog10(9999));
  checkGetLoggedMapValue(1, power);
  checkGetLoggedMapValue(5, power);
  checkGetLoggedMapValue(10, power);
  checkGetLoggedMapValue(55, power);
  checkGetLoggedMapValue(100, power);
  checkGetLoggedMapValue(1000, power);
  checkGetLoggedMapValue(5500, power);
  checkGetLoggedMapValue(8500, power);
  checkGetLoggedMapValue(9999, power);
  
  if (palettes == null)
  {
    palettes = new ArrayList<Palette>();
    loadPalettes();
  }
  
  for (int i = 1; i < variationIndex.length; i++)
  {
    variationIndex[i] = -1;
  }
  
  reset(false);
}

void reset(boolean keepPalette)
{
  pause = false;

  if (!keepPalette)
  {
    selectPalette();
  }
  
  functions.clear();
  //addSierpinskisGasket();
  //addFractalFlame(3, getVariation(random(0, variationCount)));
  int count = (int)random(2, 6);
  //Variation variation = getVariation(variationIndex);
  print("Count: " + count + ", Variations: ");
  ArrayList<Variation> variations = new ArrayList<Variation>();
  for (int i : variationIndex)
  {
    if (i == -1)
      continue;
    
    Variation variation = getVariation(i);
    variations.add(variation);
    print(variation.getVariationName() + " ");
  }
  println();
  
  addFractalFlame(count, variations);
  
  position.x = random(-1, 1);
  position.y = random(-1, 1);
  
  density = new int[width][height];
  maxDensity = 0;
  
  iterate(20);

  background(0);
  loadPixels();
}

void keyPressed()
{
  println(key);
  switch (key)
  {
    case 'q': variationIndexMove(0, 1); break;
    case 'a': variationIndexMove(0, -1); break;
    case 'w': variationIndexMove(1, 1); break;
    case 's': variationIndexMove(1, -1); break;
    case 'e': variationIndexMove(2, 1); break;
    case 'd': variationIndexMove(2, -1); break;
    case 'r': variationIndexMove(3, 1); break;
    case 'f': variationIndexMove(3, -1); break;
    case 't': variationIndexMove(4, 1); break;
    case 'g': variationIndexMove(4, -1); break;
    case 'z': variationIndexMove(5, 1); break;
    case 'h': variationIndexMove(5, -1); break;
    case 'u': variationIndexMove(6, 1); break;
    case 'j': variationIndexMove(6, -1); break;
    case 'i': variationIndexMove(7, 1); break;
    case 'k': variationIndexMove(7, -1); break;
  }
}

public void variationIndexMove(int i, int delta)
{
  variationIndex[i] += delta;
  if (variationIndex[i] >= variationCount)
  {
    variationIndex[i] = -1;
  }
  if (variationIndex[i] < -1)
  {
    variationIndex[i] = variationCount - 1;
  }
  reset(false);
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset(false);
  }
  else if (mouseButton == CENTER)
  {
    pause = false;
    for (int i = 0; i < steps; i++)
    {
      draw();
    }
    pause = true;
  }
  else if (mouseButton == RIGHT)
  {
    pause = !pause;
  }
}

void draw()
{
  if (pause)
    return;
  
  for (int i = 0; i < 100000; i++)
  {
    iterate(1);
    if (finalTransform != null)
    {
      finalTransform.calculate(position, drawPosition);
    }
    else
    {
      drawPosition.x = position.x;
      drawPosition.y = position.y;
    }
    
    int x = floor((drawPosition.x+1)*(width/2));
    int y = floor((drawPosition.y+1)*(height/2));
    
    if ((x < 0) || (x >= width) || (y < 0) || (y >= height))
      continue;
      
    int value = density[x][y];
    value++;
    density[x][y] = value;
    
    if (value > maxDensity)
      maxDensity = value;
  }
  
  render();
}

void render()
{
  stroke(255);
  noFill();
  int i = 0;
  
  int maxPow = ceil(getLog10(maxDensity));
  
  for (int x = 0; x < width; x++)
  {
    for (int y = 0; y < height; y++)
    {
      //float value = (float)density[x][y] / maxDensity;
      int strength = density[x][y];
      float value;
      if (strength == 0)
      {
        value = 0;
      }
      else
      {
        value = getLogMappedValue(strength, maxPow);
      }
      //if (strength > 0) strength = 1;
      pixels[i++] = color(value * 255);
    }
  }
  updatePixels();
}

void checkGetLoggedMapValue(int value, int maxPow)
{
  println(value + "(max " + pow(10, maxPow) + "): " + getLogMappedValue(value, maxPow));
}

float getLogMappedValue(int value, int maxPow)
{
  int power = ceil(getLog10(value+1));
  int powerFloor = getPow10(power-1);
  int powerCeiling = getPow10(power);
  float result = (float)(value - powerFloor) / (powerCeiling - powerFloor);
  result = ((float)power/(maxPow+1)) + (result / (maxPow+1));
  return result;
}

void iterate(int count)
{
  for (int i = 0; i < count; i++)
  {
    Function f = functions.get((int)random(0, functions.size()));
    f.calculate(position, out);
    position.x = out.x;
    position.y = out.y;
  }
}

void addSierpinskisGasket()
{
  functions.add(new Function() { public void calculate(PVector in, PVector out) { out.x = in.x/2; out.y = in.y/2; } });
  functions.add(new Function() { public void calculate(PVector in, PVector out) { out.x = (in.x+1)/2; out.y = in.y/2; } });
  functions.add(new Function() { public void calculate(PVector in, PVector out) { out.x = in.x/2; out.y = (in.y+1)/2; } });
}

void addFractalFlame(int functionCount, ArrayList<Variation> variations)
{
  for (int i = 0; i < functionCount; i++)
  {
    FunctionWithVariation function = getRandomFunctionWithVariation();
    //function.setPostTransform(getRandomFunctionWithVariation());
    if (variations.size() == 1)
    {
      function.addVariation(variations.get(0), 1);
    }
    else
    {
      for (Variation variation : variations)
      {
        function.addVariation(variation, random(0, 1));
      }
    }
    functions.add(function);
  }
}

FunctionWithVariation getRandomFunctionWithVariation()
{
  float a = random(-1, 1);
  float b = random(-1, 1);
  float c = random(-1, 1);
  float d = random(-1, 1);
  float e = random(-1, 1);
  float f = random(-1, 1);
  return new FunctionWithVariation(a, b, c, d, e, f);
}

float getLog10(int value)
{
  while (log10table.size() <= value)
  {
    log10table.add(log(log10table.size()) / log10);
  }
  
  return log10table.get(value);
}

int getPow10(int power)
{
  if (power <= 0)
    return 0;
  
  while (pow10table.size() <= power)
  {
    pow10table.add((int)pow(10, pow10table.size()));
  }
  
  return pow10table.get(power);
}

Variation getVariation(int i)
{
  switch (i)
  {
    case 0: return new Variation0Linear();
    case 1: return new Variation1Sinusoidal();
    case 2: return new Variation2Spherical();
    case 3: return new Variation3Swirl();
    case 4: return new Variation4Horseshoe();
    default: throw new RuntimeException(i + " is out of range.");
  }
}

abstract class Function
{
  public abstract void calculate(PVector in, PVector out);
}

class FunctionWithVariation extends Function
{
  public float a;
  public float b;
  public float c;
  public float d;
  public float e;
  public float f;
  FunctionWithVariation postTransform;
  ArrayList<BlendedVariation> blendedVariations;
  PVector intermediateXY = new PVector();
  PVector intermediateResult = new PVector();
  
  public FunctionWithVariation(float a, float b, float c, float d, float e, float f)
  {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.e = e;
    this.f = f;
    blendedVariations = new ArrayList<BlendedVariation>();
  }
  
  public void setPostTransform(FunctionWithVariation postTransform)
  {
    this.postTransform = postTransform;
  }

  public void addVariation(Variation variation, float blendingFactor)
  {
    blendedVariations.add(new BlendedVariation(variation, blendingFactor));
  }

  public void calculate(PVector in, PVector out)
  {
    //a = animate(a, 0); b = animate(b, 1); c = animate(c, 2); d = animate(d, 3); e = animate(e, 4); f = animate(f, 5);
    
    intermediateXY.x = a*in.x + b*in.y + c;
    intermediateXY.y = d*in.x + e*in.y + f;
    
    if (blendedVariations.size() == 0)
    {
      out.x = intermediateXY.x;
      out.y = intermediateXY.y;
    }
    else
    {
      out.x = 0;
      out.y = 0;
      for (BlendedVariation blendedVariation : blendedVariations)
      {
        blendedVariation.variation.calculate(intermediateXY, intermediateResult, this);
        out.x += intermediateResult.x * blendedVariation.blendingFactor;
        out.y += intermediateResult.y * blendedVariation.blendingFactor;
      }
    }
    
    if (postTransform != null)
    {
      intermediateXY.x = out.x;
      intermediateXY.y = out.y;
      postTransform.calculate(intermediateXY, out);
    }
  }
}

public float animate(float in, int index)
{
  //if (index > 0) return in; 
  float y = index * 0.1;
  return min(1, max(-1, in + (noise(frameCount * 0.01) * 2 - 1) * 0.0001, y));
}

public class BlendedVariation
{
  public Variation variation;
  public float blendingFactor;
  
  public BlendedVariation(Variation variation, float blendingFactor)
  {
    this.variation = variation;
    this.blendingFactor = blendingFactor;
  }
}

abstract class Variation
{
  public abstract void calculate(PVector in, PVector out, FunctionWithVariation params);
  
  float r(PVector in)
  {
    return in.mag();
  }
  
  float theta(PVector in) // θ
  {
    return atan(in.x/in.y);
  }
  
  float phi(PVector in) // φ
  {
    return atan(in.x/in.y);
  }
  
  float omega() // Ω
  {
    return random(1) < 0.5 ? 0 : PI;
  }
  
  float lambda() // Λ
  {
    return random(1) < 0.5 ? -1 : 1;
  }
  
  float psi() // Ψ
  {
    return random(0, 1);
  }
  
  float trunc(float value)
  {
    return floor(value);
  }
  
  public abstract String getVariationName();
}

class Variation0Linear extends Variation
{
  public String getVariationName() { return "Linear"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    out.x = in.x;
    out.y = in.y;
  }
}

class Variation1Sinusoidal extends Variation
{
  public String getVariationName() { return "Sinusoidal"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    out.x = sin(in.x);
    out.y = sin(in.y);
  }
}

class Variation2Spherical extends Variation
{
  public String getVariationName() { return "Spherical"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float i = 1 / sq(r(in));
    out.x = i * in.x;
    out.y = i * in.y;
  }
}

class Variation3Swirl extends Variation
{
  public String getVariationName() { return "Swirl"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float r = r(in);
    float sqr = sq(r);
    float sinr2 = sin(sqr);
    float cosr2 = cos(sqr);
    out.x = in.x * sinr2 - in.y * cosr2;
    out.y = in.x * cosr2 + in.y * sinr2;
  }
}

class Variation4Horseshoe extends Variation
{
  public String getVariationName() { return "Horseshoe"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float invr = (1/r(in));
    out.x = invr * (in.x-in.y) * (in.x+in.y);
    out.y = invr * 2 * in.x * in.y;
  }
}