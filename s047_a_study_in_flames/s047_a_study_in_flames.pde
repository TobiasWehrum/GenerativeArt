/*
Copyright (c) 2016 Tobias Wehrum <Tobias.Wehrum@dragonlab.de>
Distributed under the MIT License. (See accompanying file LICENSE or copy at http://opensource.org/licenses/MIT)
This notice shall be included in all copies or substantial portions of the Software.

Controls:
- Left-click to refresh.
- Middle-click to randomize all settings.
- Right-click to pause/continue.
- Q/A, W/S, E/D, R/F, T/G, Z/H, U/J, I/K to selection variations.
- Y to switch between color correction settings.
- C to switch symmetry settings.
- V to lock/unlock color palette.
- Space to make a screenshot.

Color schemes:
- "(◕ ” ◕)" by sugar!: http://www.colourlovers.com/palette/848743
- "vivacious" by plch: http://www.colourlovers.com/palette/557539/vivacious
- "Sweet Lolly" by nekoyo: http://www.colourlovers.com/palette/56122/Sweet_Lolly
- "Pop Is Everything" by jen_savage: http://www.colourlovers.com/palette/7315/Pop_Is_Everything
- "it's raining love" by tvr: http://www.colourlovers.com/palette/845564/its_raining_love
- "A Dream in Color" by madmod001: http://www.colourlovers.com/palette/871636/A_Dream_in_Color
- "Influenza" by Miaka: http://www.colourlovers.com/palette/301154/Influenza
- "Ocean Five" by DESIGNJUNKEE: http://www.colourlovers.com/palette/1473/Ocean_Five
*/

boolean pause;
int steps = 5;
int iterationStepsPerDraw = 50000;

boolean useGradient = false;
String gradientFilename = "gradientBlue1.png"; //"gradientHue240-480.png";
color[] gradient;

int[] variationIndex = new int[8];
int variationCount = 15;
int[][] density;
float[][] densityR;
float[][] densityG;
float[][] densityB;
int maxDensity;
int symmetry;
int symmetryCount = 8; // no, vertical, horizontal, 180, 120, 90, 72, 60
boolean paletteLock = false;

float col;
PVector position = new PVector();
PVector out = new PVector();
PVector drawPosition = new PVector();
Function finalTransform = null;

float log10;
ArrayList<Float> logTable = new ArrayList<Float>();
ArrayList<Float> log10table = new ArrayList<Float>();
ArrayList<Integer> pow10table = new ArrayList<Integer>();

ArrayList<Function> functions = new ArrayList<Function>();

void setup()
{
  size(768, 768);
  //fullScreen();
  //blendMode(ADD);
  //colorMode(HSB, 360, 100, 100, 255);

  log10 = log(10);
  
  /*
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
  */
  
  gradient = loadGradient(gradientFilename);
  
  if (palettes == null)
  {
    palettes = new ArrayList<Palette>();
    loadPalettes();
  }
  
  for (int i = 1; i < variationIndex.length; i++)
  {
    variationIndex[i] = -1;
  }
  
  reset();
}

void reset()
{
  pause = false;

  if (!paletteLock)
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
  println(" / Symmetry: " + symmetry + " / Palette: " + currentPalette.name);
  println();
  
  addFractalFlame(count, variations);
  
  position.x = random(-1, 1);
  position.y = random(-1, 1);
  col = random(0, 1);
  
  density = new int[width][height];
  densityR = new float[width][height];
  densityG = new float[width][height];
  densityB = new float[width][height];
  maxDensity = 0;
  
  iterate(20);

  background(0);
  loadPixels();
}

void keyPressed()
{
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
    case 'y': switchA = !switchA; println("switchA: " + switchA); break;
    case 'x': switchB = !switchB; println("switchB: " + switchB); break;
    case ' ': saveFrame("screenshot-######.png"); print("Screenshot saved!"); break;
    case 'c': symmetry = ((symmetry + 1) % symmetryCount); reset(); break;
    case 'v': paletteLock = !paletteLock; println("Palette locked: " + paletteLock); break;
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
  reset();
}

void mouseClicked()
{
  if (mouseButton == LEFT)
  {
    reset();
  }
  else if (mouseButton == CENTER)
  {
    for (int i = 0; i < variationIndex.length; i++)
    {
      variationIndex[i] = -1;
    }
    symmetry = 0;
    
    variationIndex[0] = floor(random(0, variationCount));
    for (int i = 1; i < variationIndex.length; i++)
    {
      if (random(1) < 0.5)
        break;
        
      variationIndex[1] = floor(random(0, variationCount));
    }
    
    if (random(1) > 0.66)
    {
      if (random(1) > 0.5)
      {
        float v = random(1);
        if (v > 0.66)
        {
          symmetry = 1;
        }
        else if (v > 0.33)
        {
          symmetry = 2;
        }
        else
        {
          symmetry = 3;
        }
      }
      else
      {
        symmetry = floor(random(4, symmetryCount));
      }
    }
    reset();
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
  
  for (int i = 0; i < iterationStepsPerDraw; i++)
  {
    iterate(1);
    
    float drawCol;
    if (finalTransform != null)
    {
      finalTransform.calculate(position, drawPosition);
      drawCol = (col + finalTransform.col) / 2;
    }
    else
    {
      drawPosition.x = position.x;
      drawPosition.y = position.y;
      drawCol = col;
    }
    
    plot(drawPosition.x, drawPosition.y, drawCol);
    
    // symmetry: no, vertical, horizontal, 180, 120, 90, 72, 60
    if (symmetry > 0)
    {
      if (symmetry == 1)
      {
        plot(-drawPosition.x, drawPosition.y, drawCol);
      }
      else if (symmetry == 2)
      {
        plot(drawPosition.x, -drawPosition.y, drawCol);
      }
      else
      {
        int rotationCount = symmetry - 2;
        float delta = PI*2 / (rotationCount+1);
        for (int j = 0; j < rotationCount; j++)
        {
          drawPosition.rotate(delta);
          plot(drawPosition.x, drawPosition.y, drawCol);
        }
      }
    }
  }
  
  render();
}

void plot(float posX, float posY, float drawCol)
{
  float centerX = width/2f;
  float centerY = height/2f;
  float smallerSide = min(width, height);
  int x = floor(centerX+posX*(smallerSide/2));
  int y = floor(centerY+posY*(smallerSide/2));
  
  if ((x < 0) || (x >= width) || (y < 0) || (y >= height))
    return;
    
  int value = density[x][y];
  value++;
  density[x][y] = value;
  
  if (value > maxDensity)
    maxDensity = value;

  color drawColor = useGradient
                      ? getColor(gradient, drawCol)
                      : currentPalette.getPercent(drawCol);
  densityR[x][y] += red(drawColor)/255;
  densityG[x][y] += blue(drawColor)/255;
  densityB[x][y] += green(drawColor)/255;
  //densityR[x][y] = (densityR[x][y]+red(drawColor)/255)/2;
  //densityG[x][y] = (densityG[x][y]+blue(drawColor)/255)/2;
  //densityB[x][y] = (densityB[x][y]+green(drawColor)/255)/2;
}

boolean switchA = true;
boolean switchB = true;

void render()
{
  //float gammaAdjust = 4;
  
  stroke(255);
  noFill();
  int i = 0;
  
  int maxPow = ceil(getLog10(maxDensity));
  
  for (int y = 0; y < height; y++)
  {
    for (int x = 0; x < width; x++)
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
        //value = getLogMappedValue(strength, maxPow);
        if (switchA)
        {
          //value = getLogMappedValue(strength, maxPow);
          value = getLog(strength)/strength;
        }
        else
        {
          value = strength * getLog(maxDensity) / maxDensity;
        }
        //value = strength;
      }
      
      //float multiplier = getLog(strength)/strength;
      float multiplier = value;
      float red = densityR[x][y] * multiplier;
      float green = densityB[x][y] * multiplier;
      float blue = densityG[x][y] * multiplier;
      
      /*
      if (switchB)
      {
        red = pow(red, 1/gammaAdjust);
        green = pow(green, 1/gammaAdjust);
        blue = pow(blue, 1/gammaAdjust);
      }
      */
      
      //float red = densityR[x][y];
      //float green = densityB[x][y];
      //float blue = densityG[x][y];
      pixels[i++] = color(red * 255, green * 255, blue * 255);

      //pixels[i++] = color(value * 255);
      //color c = getColor(gradient, value);
      //pixels[i++] = c;
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
    col = (col + f.col) / 2;
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
    function.col = random(0, 1);
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

float getLog(int value)
{
  while (logTable.size() <= value)
  {
    logTable.add(log(log10table.size()));
  }
  
  return logTable.get(value);
}

float getLog10(int value)
{
  while (log10table.size() <= value)
  {
    log10table.add(getLog(log10table.size()) / log10);
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
    case 5: return new Variation5Polar();
    case 6: return new Variation6Handkerchief();
    case 7: return new Variation7Heart();
    case 8: return new Variation8Disc();
    case 9: return new Variation9Spiral();
    case 10: return new Variation10Hyperbolic();
    case 11: return new Variation18Exponential();
    case 12: return new Variation19Power();
    case 13: return new Variation21Rings();
    case 14: return new Variation22Fan();
    default: throw new RuntimeException(i + " is out of range.");
  }
}

abstract class Function
{
  public float col;
  
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
    return atan2(in.x, in.y);
  }
  
  float phi(PVector in) // φ
  {
    return atan2(in.y, in.x);
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
  
  float mod(float value)
  {
    return (abs(value) % 1) * ((value > 0) ? 1 : -1);
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

class Variation5Polar extends Variation
{
  public String getVariationName() { return "Polar"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    out.x = theta(in)/PI;
    out.y = r(in)-1;
  }
}

class Variation6Handkerchief extends Variation
{
  public String getVariationName() { return "Handkerchief"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float r = r(in);
    float theta = theta(in);
    out.x = r * sin(theta + r);
    out.y = r * cos(theta - r);
  }
}

class Variation7Heart extends Variation
{
  public String getVariationName() { return "Heart"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float r = r(in);
    float thetaR = r * theta(in);
    out.x = r * sin(thetaR);
    out.y = r * -cos(thetaR);
  }
}

class Variation8Disc extends Variation
{
  public String getVariationName() { return "Disc"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float piR = r(in) * PI;
    float thetaByPi = theta(in)/PI;
    out.x = thetaByPi * sin(piR);
    out.y = thetaByPi * cos(piR);
  }
}

class Variation9Spiral extends Variation
{
  public String getVariationName() { return "Spiral"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float r = r(in);
    float d1r = 1/r;
    float theta = theta(in);
    out.x = d1r * (cos(theta) + sin(r));
    out.y = d1r * (sin(theta) - cos(r));
  }
}

class Variation10Hyperbolic extends Variation
{
  public String getVariationName() { return "Hyperbolic"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float r = r(in);
    float theta = theta(in);
    out.x = sin(theta)/r;
    out.y = r * cos(theta);
  }
}

class Variation18Exponential extends Variation
{
  public String getVariationName() { return "Exponential"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float expx1 = exp(in.x - 1);
    out.x = expx1 * cos(PI*in.y);
    out.y = expx1 * sin(PI*in.y);
  }
}

class Variation19Power extends Variation
{
  public String getVariationName() { return "Power"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float theta = theta(in);
    float costheta = cos(theta);
    float sintheta = sin(theta);
    float mult = pow(r(in), sintheta);
    out.x = mult * costheta;
    out.y = mult * sintheta;
  }
}

class Variation21Rings extends Variation
{
  public String getVariationName() { return "Rings"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float r = r(in);
    float theta = theta(in);
    float c = params.c;
    float c2 = c*c;
    float mult = (r + c2) * mod(2*c2) - c2 + r*(1-c2);
    out.x = mult * cos(theta);
    out.y = mult * sin(theta);
  }
}

class Variation22Fan extends Variation
{
  public String getVariationName() { return "Fan"; }
  
  public void calculate(PVector in, PVector out, FunctionWithVariation params)
  {
    float c = params.c;
    float f = params.f;
    float c2 = c*c;
    float t = PI*c2;
    float mirror = 1;
    float theta = theta(in);
    if ((theta+f)*(mod(t)) <= t/2)
      mirror = -1;
      
    float r = r(in);
    float mult = (r + c2) * mod(2*c2) - c2 + r*(1-c2);
    out.x = r * cos(theta - t/2 * mirror);
    out.y = r * sin(theta - t/2 * mirror);
  }
}