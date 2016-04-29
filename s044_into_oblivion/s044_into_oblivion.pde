import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
BeatDetect beat;
FFT fft;
float[] previousValues;
float[] rotation;
PVector[][] prevPos;
PVector[][] prevPosRot;
int skipMillis = 5000;
boolean paused = false;
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
  //player = minim.loadFile("Mayhem - ON Trax Vol. 4 - 07 Push Every Button.mp3");
  //player = minim.loadFile("Mayhem - ON Trax Vol. 4 - 07 Push Every Button (short).mp3");
  //player = minim.loadFile("Nexus Child - Rebirth.mp3");
  //player = minim.loadFile("Nexus Child - Rebirth (short).mp3");
  //player = minim.loadFile("_voxelcountrygarden.mp3"); scaling = 5;
  //player = minim.loadFile("_87 Hopes and Dreams.mp3");
  //player = minim.loadFile("_100 MEGALOVANIA.mp3");
  noCursor();
  
  player = null;
  
  //selectXML();
  reset();
}

void selectXML()
{
  if (player != null)
  {
    paused = true;
    player.pause();
  }
  
  selectInput("Select config XML", "fileSelected");
}

void fileSelected(File selection)
{
  if (selection != null)
  {
    settingsXML = selection.getAbsolutePath();
    reset();
  }
  else if (player != null)
  {
    paused = false;
    player.play();
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
  
  String song = xml.getString("song", "Mayhem - ON Trax Vol. 4 - 07 Push Every Button (short).mp3");
  scaling = xml.getFloat("scaling", 3);
  String gradientFilename = xml.getString("gradient", "gradientHue240-480.png");
  boolean gradientReverse = xml.getString("gradientReverse", "false").equals("true");
  scalingOn = !xml.getString("keepSize", "false").equals("true");
  
  player = minim.loadFile(song);
  
  beat = new BeatDetect();
  fft = new FFT(player.left.size(), 44100);
  //fft.window(FFT.HAMMING);
  previousValues = new float[fft.specSize()/10];
  prevPos = new PVector[previousValues.length][20];
  rotation = new float[previousValues.length];
  prevPosRot = new PVector[2][50];

  player.play(0);
  
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
  
  paused = false;
  loading = false;
}

void keyPressed()
{
  if (key == '1')
    scalingOn = !scalingOn;
  
  if (player != null)
  {
    if (keyCode == LEFT)
    {
      player.skip(-skipMillis);
      player.play();
      paused = false;
    }
    else if (keyCode == RIGHT)
    {
      player.skip(skipMillis);
      player.play();
      paused = false;
    }
    else if (keyCode == UP)
    {
      reset();
    }
    else if (keyCode == DOWN)
    {
      if (player.isPlaying())
      {
        player.pause();
        paused = true;
      }
      else
      {
        player.play();
        paused = false;
      }
    }
  }
  
  if (key == ' ')
  {
    selectXML();
  }
}

void draw()
{
  if ((player == null) || paused || loading)
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
  fft.forward(player.mix);

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

void drawSatellites()
{
  stroke(255, 255, 255, 255);
  strokeCap(NORMAL);
  float satelliteDistance = height*0.4;
  //float satelliteRadius = 20;
  float angle = player.position() * 0.001;
  for (int i = 0; i < prevPosRot.length; i++)
  {
    float addDistance = player.mix.get(0) * height * 0.1;
    float x = width/2 + cos(angle) * (satelliteDistance + addDistance);
    float y = height/2 + sin(angle) * (satelliteDistance + addDistance);
    PVector[] prevPosRotArr = prevPosRot[i];
    for (int j = 0; j < prevPosRotArr.length-1; j++)
    {
      prevPosRotArr[j] = prevPosRotArr[j+1];
    }
    prevPosRotArr[prevPosRotArr.length-1] = new PVector(x, y);
    for (int j = 0; j < prevPosRotArr.length-1; j++)
    {
      PVector from = prevPosRotArr[j];
      PVector to = prevPosRotArr[j+1];
      if ((from != null) && (to != null))
        line(from.x, from.y, to.x, to.y);
    }
    angle += PI*2 / prevPosRot.length;
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
  int count = player.bufferSize();
  float distance = (float)width / count;
  for (int i = 0; i < count - 1; i++)
  {
    line(distance*i, 50 + player.left.get(i)*50, distance*(i+1), 50 + player.left.get(i+1)*50);
    line(distance*i, 150 + player.right.get(i)*50, distance*(i+1), 150 + player.right.get(i+1)*50);
  }
}