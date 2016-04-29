import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
FFT fft;
float[] previousValues;
float[] rotation;
PVector[][] prevPos;
PVector[][] prevPosRot;
float scaling = 3;

void setup()
{
  //size(displayWidth, displayHeight);
  //size(600, 600);
  fullScreen();
  colorMode(HSB, 360, 255, 255, 255);

  //blendMode(ADD);

  minim = new Minim(this);
  //player = minim.loadFile("Mayhem - ON Trax Vol. 4 - 07 Push Every Button.mp3");
  player = minim.loadFile("Mayhem - ON Trax Vol. 4 - 07 Push Every Button (short).mp3");
  //player = minim.loadFile("Nexus Child - Rebirth.mp3");
  //player = minim.loadFile("Nexus Child - Rebirth (short).mp3");
  //player = minim.loadFile("_voxelcountrygarden.mp3"); scaling = 5;
  //player = minim.loadFile("_87 Hopes and Dreams.mp3");
  //player = minim.loadFile("_100 MEGALOVANIA.mp3");
  meta = player.getMetaData();
  beat = new BeatDetect();
  fft = new FFT(player.left.size(), 44100);
  //fft.window(FFT.HAMMING);
  previousValues = new float[fft.specSize()/10];
  prevPos = new PVector[previousValues.length][20];
  rotation = new float[previousValues.length];
  prevPosRot = new PVector[2][50];

  //player.loop();
  player.play();
  noCursor();

  background(255);
}

boolean scalingOn = true;

void keyPressed()
{
  if (key == '1')
    scalingOn = !scalingOn;
}

float rotAngle;

void draw()
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

  int lineSize = 2;
  int scale = 4;

  fft.forward(player.mix);

  float totalAvg = 0;
  int totalCount = 0;

  noStroke();
  fill(120);
  int size = 10;
  for (int n = 0; n < fft.specSize()-size; n += size) {
    float percent = (float)n / (fft.specSize()-size);
    float avg = 0;
    for (int i = n; i < n+size; i++)
      avg += fft.getBand(n);
    avg = avg * lerp(4, 8, percent) * scaling / size;

    float previous = previousValues[n/size];
    previous *= 0.9;
    previous = max(avg, previous);
    //previous = (avg+previous)/2;
    previousValues[n/size] = previous;

    // draw the line for frequency band n, scaling it by 4 so we can see it a bit better
    //rect(lineSize + n*lineSize, height, lineSize*size, -previous);
    
    totalAvg += previous;
    totalCount++;
  }
  
  totalAvg /= totalCount;

  //float centerFrequency = fft.getAverageCenterFrequency();
  
  stroke(255, 255, 255, 255);

  strokeCap(NORMAL);
  float satelliteDistance = height*0.4;
  float satelliteRadius = 20;
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
      /*
      if ((from != null) && (to != null))
        line(from.x, from.y, to.x, to.y);
      */
    }
    angle += PI*2 / prevPosRot.length;
  }

  float positionRadius = height*0.3;
  if (scalingOn)
    positionRadius *= (1+totalAvg*0.01);

  //rotAngle += totalAvg*0.0001;

  stroke(255);
  fill(255);
  
  translate(width/2, height/2);
  rotate(rotAngle);
  translate(-width/2, -height/2);
  //ellipse(width/2, 0, 10, 10);
  
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
    color col = color(lerp(240, 480, percent) % 360, 255, 255);
    //color col = color(lerp(360, 60, percent) % 360, 255, 255);
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

  /*
  int i = 1;
   int c = 0;
   while (i*2-1 < fft.specSize())
   {
   int avg = 0;
   for (int j = i-1; j < i*2-1; j++)
   avg += fft.getBand(j);
   avg = avg * scale / i;
   
   rect(10 + c*10, height, 10, -avg);
   
   i *= 2;
   c++;
   }
   */

  fill(255);
  /*
  for (int n = 0; n < fft.specSize(); n++) {
   // draw the line for frequency band n, scaling it by 4 so we can see it a bit better
   rect(lineSize + n*lineSize, height, lineSize, -fft.getBand(n)*scale);
   }
   */

/*
  stroke(255);
   noFill();
   // draw the waveforms
   for (int i = 0; i < player.bufferSize() - 1; i++)
   {
   line(i, 50 + player.left.get(i)*50, i+1, 50 + player.left.get(i+1)*50);
   line(i, 150 + player.right.get(i)*50, i+1, 150 + player.right.get(i+1)*50);
   }
   */

  /*
  float t = map(mouseX, 0, width, 0, 1);
   beat.detect(player.mix);
   fill(#1A1F18, 20);
   noStroke();
   rect(0, 0, width, height);
   translate(width/2, height/2);
   noFill();
   fill(-1, 10);
   if (beat.isOnset()) rad = rad*0.9;
   else rad = 70;
   ellipse(0, 0, 2*rad, 2*rad);
   stroke(-1, 50);
   int bsize = player.bufferSize();
   for (int i = 0; i < bsize - 1; i+=5)
   {
   float x = (r)*cos(i*2*PI/bsize);
   float y = (r)*sin(i*2*PI/bsize);
   float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
   float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
   line(x, y, x2, y2);
   }
   beginShape();
   noFill();
   stroke(-1, 50);
   for (int i = 0; i < bsize; i+=30)
   {
   float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
   float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
   vertex(x2, y2);
   pushStyle();
   stroke(-1);
   strokeWeight(2);
   point(x2, y2);
   popStyle();
   }
   endShape();
   // if (flag)
   // showMeta();
   */
}