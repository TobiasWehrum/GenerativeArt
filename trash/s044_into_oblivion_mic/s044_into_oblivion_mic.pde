import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput microphone;
FFT fft;
float[] previousValues;
float[] rotation;
PVector[][] prevPos;
PVector[][] prevPosRot;
int skipMillis = 5000;
float totalAvg;
boolean scalingOn = true;
float rotAngle;
boolean loading = false;

String settingsXML = "default.xml";
float scaling;
color[] gradient;

void setup()
{
  //size(displayWidth, displayHeight);
  //size(600, 600);
  fullScreen();
  //colorMode(HSB, 360, 255, 255, 255);

  //blendMode(ADD);

  minim = new Minim(this);
  microphone = minim.getLineIn(Minim.STEREO, 4096);
  fft = new FFT(microphone.bufferSize(), microphone.sampleRate());
  previousValues = new float[fft.specSize()/10];
  prevPos = new PVector[previousValues.length][20];
  rotation = new float[previousValues.length];
  prevPosRot = new PVector[2][50];
  noCursor();
  
  //selectXML();
  reset();
}

void selectXML()
{
  selectInput("Select config XML", "fileSelected");
}

void fileSelected(File selection)
{
  if (selection != null)
  {
    settingsXML = selection.getAbsolutePath();
    reset();
  }
}

void reset()
{
  loading = true;
  
  XML xml;
  try
  {
    xml = loadXML(settingsXML);
  }
  catch (Exception e)
  {
    selectXML();
    return;
  }
  
  scaling = xml.getFloat("scaling", 3);
  String gradientFilename = xml.getString("gradient", "gradientHue240-480.png");
  boolean gradientReverse = xml.getString("gradientReverse", "false").equals("true");
  scalingOn = !xml.getString("keepSize", "false").equals("true");
  
  PImage gradientImage = loadImage(gradientFilename);
  gradient = new color[gradientImage.width];
  for (int i = 0; i < gradientImage.width; i++)
  {
    gradient[i] = gradientImage.get(gradientReverse ? (gradientImage.width - i - 1) : i, 0);
  }

  background(50);
  fill(0, 50);
  noStroke();
  for (int i = 0; i < 10; i++)
    rect(0, 0, width, height);
  
  loading = false;
}

void keyPressed()
{
  if (key == '1')
    scalingOn = !scalingOn;
  
  /*
  if (keyCode == LEFT)
  {
    player.skip(-skipMillis);
    player.play();
    paused = false;
  }
  */

  if (key == ' ')
  {
    selectXML();
  }
}

void draw()
{
  if (loading)
    return;
  
  resetBackground();

  calculateFFTValues();
  //drawFFTValues();

  //drawSatellites();

  drawCenterVisualizer();

  //drawFFT();
  //drawWaveform();
}

void resetBackground()
{
  fill(0, 50);
  
  /*
  beat.detect(player.mix);
  if (beat.isOnset())
  {
    fill(255, 0, 255, 50);
  }
  */

  noStroke();
  rect(0, 0, width, height);
  //background(0);
}

void calculateFFTValues()
{
  fft.forward(microphone.mix);

  totalAvg = 0;
  int totalCount = 0;

  noStroke();
  fill(120);
  int size = 10;
  for (int n = 0; n < fft.specSize()-size; n += size) {
    float percent = (float)n / (fft.specSize()-size);
    float avg = 0;
    for (int i = n; i < n+size; i++)
    {
      avg += fft.getBand(n);
      //avg = max(avg, fft.getBand(n) * size);
    }
    avg = avg * lerp(4, 8, percent) * scaling / size;

    float previous = previousValues[n/size];
    previous *= 0.9;
    previous = max(avg, previous);
    //previous = (avg+previous)/2;
    previousValues[n/size] = previous;

    totalAvg += previous;
    totalCount++;
  }
  
  totalAvg /= totalCount;
}

void drawFFTValues()
{
  int scale = 4;
  noStroke();
  fill(255);
  int count = previousValues.length;
  int lineSize = width / (count+2);
  for (int n = 0; n < count; n++) {
    rect(lineSize + n*lineSize, height, lineSize, -previousValues[n]);
  }  
}

void drawCenterVisualizer()
{
  float positionRadius = height*0.3;
  if (scalingOn)
    positionRadius *= (1+totalAvg*0.01);
  else
    positionRadius *= 1.35;

  //rotAngle += totalAvg*0.0001;
  translate(width/2, height/2);
  rotate(rotAngle);
  translate(-width/2, -height/2);
  
  noFill();
  noStroke();

  strokeCap(SQUARE);
  int c = previousValues.length;
  for (int i = 0; i < previousValues.length; i++)
  { 
    int count = 20;
    float startAngle = (i*PI/100);
    float deltaAngle = PI*2 / count;
    float value = previousValues[i];
    float percent = (float)i/previousValues.length;
    /*
    color col = (percent <= 0.5f)
      ? lerpColor(color(255, 0, 0), color(0, 0, 255), percent*2)
      : lerpColor(color(0, 0, 255), color(255, 255, 0), (percent-0.5f)*2);
    */
    //color col = color(lerp(240, 480, percent) % 360, 255, 255);
    //color col = color(lerp(360, 60, percent) % 360, 255, 255);
    color col = gradient[min((int)(gradient.length * percent), gradient.length)];
    fill(col, 100);
    //stroke(col, 100);
    float s = max(2, value*0.5f*positionRadius/360f);//, 1+cos(frameCount*0.5+i)*0.5);
    //float distance = percent*positionRadius;
    float distance = positionRadius-(percent*positionRadius*value/40);
    distance = max(-positionRadius, distance);
    //float distance = percent*positionRadius-value;
    //float distance = value;

    //rotation[i] += value*0.0001;
    //float r = rotation[i];

    for (int j = 0; j < count; j++)
    {
      float a = startAngle + deltaAngle * j;
      if (j%2 == 0) a -= startAngle*2;

      PVector prev = prevPos[i][j];
      PVector curr = new PVector(width/2 + cos(a) * distance, height/2 + sin(a) * distance);

      //strokeWeight(1);
      //ellipse(width/2 + cos(a) * distance, height/2 + sin(a) * distance, s, s);
      if (prev != null)
      {
        //strokeWeight(s);
        //line(prev.x, prev.y, curr.x, curr.y);
        float dx = prev.x - curr.x;
        float dy = prev.y - curr.y;
        float d = sqrt(dx*dx + dy*dy);
        pushMatrix();
        /*
        translate(width/2, height/2);
         rotate(r);
         translate(-width/2, -height/2);
         */
        translate(curr.x, curr.y);
        rotate(atan2(dy, dx));
        rect(0, -s/2, d, s);
        popMatrix();
      }

      prevPos[i][j] = curr;
    }
  }
}

void drawFFT()
{
  int scale = 4;
  noStroke();
  fill(255);
  int count = fft.specSize();
  int lineSize = width / (count+2);
  for (int n = 0; n < count; n++) {
    rect(lineSize + n*lineSize, height, lineSize, -fft.getBand(n)*scale);
  }  
}

void drawWaveform()
{
  stroke(255);
  noFill();
  int count = microphone.bufferSize();
  float distance = (float)width / count;
  for (int i = 0; i < count - 1; i++)
  {
    line(distance*i, 50 + microphone.left.get(i)*50, distance*(i+1), 50 + microphone.left.get(i+1)*50);
    line(distance*i, 150 + microphone.right.get(i)*50, distance*(i+1), 150 + microphone.right.get(i+1)*50);
  }
}