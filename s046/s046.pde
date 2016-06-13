import java.lang.reflect.*;

static final int LOG_2_8287 = LogTable.log_2(8287);
static final int LOG_2_8363 = LogTable.log_2(8363);
static final int LOG_2_1712 = LogTable.log_2(1712);

class SampleData
{
  int index;
  int counter;
  float radius;
  int length;
  short[] sampleData;
  boolean looping;
  
  public SampleData(int index, int counter, Sample sample)
  {
    this.index = index;
    this.counter = counter;
    radius = 0;
    sampleData = sample.sample_data;
    length = sample.sample_data_length;
    looping = sample.loop_length > 1;
  }
}

class ChannelInfo
{
  int index;
  Channel channel;
  SampleData currentSample;
  int portamento;
  
  public ChannelInfo(int index, Channel channel)
  {
    this.index = index;
    this.channel = channel;
  }
  
  public void setCurrentSample(SampleData sample)
  {
    currentSample = sample;
    portamento = 0;
  }
  
  public boolean isSilent()
  {
    try
    {
      return (boolean) fieldChannelSilent.get(channel);
    }
    catch (Exception e)
    {
      return true;
    }
  }
  
  public float getCurrentStepLog()
  {
    try
    {
      /*
      return (log((int) fieldChannelStep.get(channel)) / log(2)) * 100;
      */
      
      int period = (int) fieldChannelPeriod.get(channel);
      int log_2_sampling_rate = (int) fieldChannelLog2SamplingRate.get(channel);
      if( period < 32 ) {
        period = 32;
      }
      if( period > 32768 ) {
        period = 32768;
      }
      int log_2_freq;
      if(module.linear_periods) {
        log_2_freq = LOG_2_8363 + ( 4608 - period << IBXM.FP_SHIFT ) / 768;
      } else {
        log_2_freq = module.pal ? LOG_2_8287 : LOG_2_8363;
        log_2_freq = log_2_freq + LOG_2_1712 - LogTable.log_2( period );
      }
      //log_2_freq += ( channel.key_add << IBXM.FP_SHIFT ) / 12;
      //return LogTable.raise_2(log_2_freq - log_2_sampling_rate);
      return (log(LogTable.raise_2(log_2_freq - log_2_sampling_rate)) / log(2)) * 100;
    }
    catch (Exception e)
    {
      return -5;
    }
  }
  
  public float getCurrentStepLogMapped()
  {
    float value = getCurrentStepLog();
    value -= 1000;
    value /= 500;
    return value;
  }
  
  public int getVolume()
  {
    if (isSilent())
      return 0;
      
    return channel.chanvolfinal;
  }
}

SampleData[] samples;
ChannelInfo[] channels;

int usedSampleCount;

//Field fieldChannelStep;
Field fieldChannelSilent;
Field fieldChannelPeriod;
Field fieldChannelLog2SamplingRate;

Player player;
Module module;
IBXM ibxm;

void setup()
{
  //size(displayWidth, displayHeight);
  size(600, 600);
  //fullScreen();
  
  //colorMode(HSB, 360, 255, 255, 255);
  //blendMode(ADD);
  
  audioSetup();
  reset();
}

void prepare()
{
  usedSampleCount = 0;
  
  player = mod.player;
  module = player.module;
  ibxm = player.ibxm;
  Instrument[] instruments = module.instruments;
  
  samples = new SampleData[instruments.length];
  for (int i = 0; i < instruments.length; i++)
  {
    Instrument instrument = mod.oldsamples.get(i);
    Sample sample = instrument.samples[0];
    
    samples[i] = new SampleData(i + 1, usedSampleCount, sample);
    
    if (sample.sample_data_length > 0)
      usedSampleCount++;
  }

  channels = new ChannelInfo[module.get_num_channels()];
  for (int i = 0; i < channels.length; i++)
  {
    channels[i] = new ChannelInfo(i + 1, ibxm.channels[i]);
  }
  
  background(50);
  fill(0, 50);
  noStroke();
  for (int i = 0; i < 10; i++)
    rect(0, 0, width, height);
    
  try
  {
    //fieldChannelStep = Channel.class.getDeclaredField("step");
    //fieldChannelStep.setAccessible(true);

    fieldChannelPeriod = Channel.class.getDeclaredField("period");
    fieldChannelPeriod.setAccessible(true);

    fieldChannelLog2SamplingRate = Channel.class.getDeclaredField("log_2_sampling_rate");
    fieldChannelLog2SamplingRate.setAccessible(true);
    
    fieldChannelSilent = Channel.class.getDeclaredField("silent");
    fieldChannelSilent.setAccessible(true);
  }
  catch (Exception e)
  {
  }
}

void executeDraw()
{
  resetBackground();
  
  noStroke();
  fill(255);
  
  for (int i = 0; i < channels.length; i++)
  {
    ChannelInfo channelInfo = channels[i];
    float value = channelInfo.getCurrentStepLogMapped();
    if (channelInfo.isSilent())
      continue;
    
    fill(getColor((float)channelInfo.currentSample.counter / (usedSampleCount-1)));
    
    //print((int)stepLog + " | ");
    //print((int)(stepLog * 10)/10f + " | ");
    
    float rectWidth = width / channels.length;
    float leftX = i * rectWidth;
    float y = (1 - value) * height;
    rect(leftX, y - 5, rectWidth, 10);  
  }
  //println();
  //println(player.play_position);
}

void resetBackground()
{
  fill(0, 50);
  noStroke();
  rect(0, 0, width, height);
  //background(0);
}

public void grabNewdata(PortaMod b) {
  NoteData note = b.localnotes;
  /* Available from NoteData objects:
  channel, currentrealrow, currentrow, currentseq, effect,
  effparam, inst, note, seqlength, timestamp, vol
  */

  if(note.channel == 0) {
    //println(note.currentrealrow + "   " + note.note);
  }
  
  ChannelInfo channel = channels[note.channel];
  if (note.inst != 0)
  {
    //println("CURRENT PORTAMENTO: " + log(channel.portamento) / log(2));
    SampleData sample = getInstrumentSampleData(note.inst);
    channel.setCurrentSample(sample);
  }
  
  if (note.effect == 1)
  {
    channel.portamento += note.effparam;
  }
  else if (note.effect == 2)
  {
    channel.portamento -= note.effparam;
  }
}

public SampleData getInstrumentSampleData(int instrument)
{
  return samples[instrument - 1];
}