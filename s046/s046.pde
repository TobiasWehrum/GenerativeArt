int cellCountX = 60;
int cellCountY = 60;
int cellWidth;
int cellHeight;

float extents;
float visualRadius;
float rotationAngle;

void setup()
{
  //size(displayWidth, displayHeight);
  size(600, 600);
  //fullScreen();

  //colorMode(HSB, 360, 255, 255, 255);
  //blendMode(ADD);

  audioSetup();
  reset();

  extents = min(width, height);
  visualRadius = extents / 2;

  frameRate(30);
}

void prepare()
{
  prepareAnalysis();

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
    }
  }

  rotationAngle = 0;

  background(50);
  fill(0, 50);
  noStroke();
  for (int i = 0; i < 10; i++)
    rect(0, 0, width, height);
}

void executeDraw()
{
  rotationAngle += 0.03;

  resetBackground();

  noStroke();
  fill(255);

  noStroke();

  for (ChannelInfo channel : channels)
    channel.update();

  for (ChannelInfo channel : channels)
  {
    for (InstrumentChannelInfo instrumentChannelInfo : channel.instrumentChannelInfos)
    {
      instrumentChannelInfo.draw();
    }
  }

  //debugDrawChannelPitch();
  //debugDrawChannelInstruments();
}

void resetBackground()
{
  //fill(0, 50);
  //noStroke();
  //rect(0, 0, width, height);
  background(0);
}

class InstrumentChannelInfo
{
  ChannelInfo channel;
  InstrumentData instrument;
  float value;
  float visible;
  //float angle;
  boolean active;
  PVector[] prevPosRotArr;

  InstrumentChannelInfo(ChannelInfo channel, InstrumentData instrument)
  {
    this.channel = channel;
    this.instrument = instrument;
    prevPosRotArr = new PVector[floor(160/module.get_num_channels())];
  }

  void update()
  {
    if (active)
    {
      if (channel.isSilent())
      {
        value = 0;
      }
      else
      {
        value = channel.getCurrentStepLogMapped();
      }
    }
    else
    {
      value = 0;
    }
  }

  void draw()
  {
    color c = getColor((float)instrument.counter / (usedInstruments.size()-1));
    stroke(c, 255);
    fill(c, 50);
    strokeCap(NORMAL);
    
    float angle = rotationAngle + ((float)channel.index/channels.length) * (PI*2);
    
    PVector center = new PVector(width/2f, height/2f);
    
    float satelliteDistanceInner = 20;
    float satelliteDistanceOuter = 20;
    float distance = satelliteDistanceInner + value * (visualRadius - satelliteDistanceInner - satelliteDistanceOuter);
    float dx = cos(angle);
    float dy = sin(angle);
    float x = center.x + dx * distance;
    float y = center.y + dy * distance;
    for (int j = 0; j < prevPosRotArr.length-1; j++)
    {
      prevPosRotArr[j] = prevPosRotArr[j+1];
    }
    prevPosRotArr[prevPosRotArr.length-1] = new PVector(x, y);
    
    /*
    if (prevPosRotArr[0] != null)
      line(width/2, height/2, prevPosRotArr[0].x, prevPosRotArr[0].y);
    */
    
    for (int i = 0; i < 1; i++)
    {
      boolean mirror = i == 1;
      
      PVector lastDrawn = null;
      for (int j = 0; j < prevPosRotArr.length; j++)
      {
        PVector from = prevPosRotArr[j];
        if (from != null)
        {
          PVector delta = PVector.sub(from, center);
          if (mirror)
            delta.mult(-1);
            
          if (lastDrawn == null)
          {
            PVector shortDelta = new PVector(delta.x, delta.y);
            shortDelta.normalize();
            shortDelta.mult(satelliteDistanceInner);
            beginShape();
            vertex(center.x + shortDelta.x, center.y + shortDelta.y);
          }
          
          vertex(center.x + delta.x, center.y + delta.y);
          lastDrawn = from;
        }
        else if (lastDrawn != null)
        {
          PVector delta = PVector.sub(lastDrawn, center);
          if (mirror)
            delta.mult(-1);
            
          delta.normalize();
          delta.mult(satelliteDistanceInner);
          vertex(center.x + delta.x, center.y + delta.y);
          endShape();
          lastDrawn = null;
        }
        /*
        PVector to = prevPosRotArr[j+1];
        if ((from != null) && (to != null))
          line(from.x, from.y, to.x, to.y);
        */
      }
      if (lastDrawn != null)
      {
        PVector delta = PVector.sub(lastDrawn, center);
        delta.normalize();
        delta.mult(satelliteDistanceInner);
        vertex(center.x + delta.x, center.y + delta.y);
        endShape();
        lastDrawn = null;
      }
    }
    
    //if (active)
    //  ellipse(x, y, 20, 20);
    
    //angle += PI*2 / prevPosRotArr.length;
    
    /*
    float blockHeight = 10;
    float rectWidth = width / channels.length;
    float leftX = channel.index * rectWidth;
    float y = (1 - value) * height;
    rect(leftX, y - blockHeight / 2, rectWidth, blockHeight);
    */
  }
}