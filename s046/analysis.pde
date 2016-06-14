import java.lang.reflect.*;

static final int LOG_2_8287 = LogTable.log_2(8287);
static final int LOG_2_8363 = LogTable.log_2(8363);
static final int LOG_2_1712 = LogTable.log_2(1712);

class InstrumentData
{
  int index;
  int counter;
  float radius;
  int length;
  short[] sampleData;
  boolean looping;
  
  public InstrumentData(int index, int counter, Sample sample)
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
  InstrumentData currentInstrument;
  InstrumentChannelInfo[] instrumentChannelInfos;
  float endTime;
  
  public ChannelInfo(int index, Channel channel)
  {
    this.index = index;
    this.channel = channel;
    
    instrumentChannelInfos = new InstrumentChannelInfo[usedInstruments.size()];
    for (int i = 0; i < usedInstruments.size(); i++)
    {
      instrumentChannelInfos[i] = new InstrumentChannelInfo(this, usedInstruments.get(i));
    }
  }
  
  public void setCurrentInstrument(InstrumentData instrument)
  {
    deactivateCurrentInstrument();
    
    currentInstrument = instrument;
    
    if (currentInstrument.looping)
    {
      endTime = -1;
    }
    else
    {
      endTime = player.play_position + currentInstrument.length;
    }
    
    if (currentInstrument != null)
    {
      instrumentChannelInfos[currentInstrument.counter].active = true;
    }
  }
  
  public void deactivateCurrentInstrument()
  {
    if (currentInstrument != null)
    {
      instrumentChannelInfos[currentInstrument.counter].active = false;
      currentInstrument = null;
    }
  }
  
  public void update()
  {
    /*
    if ((currentInstrument != null) && isSilent())
    {
      deactivateCurrentInstrument();
    }
    */
    
    for (InstrumentChannelInfo info : instrumentChannelInfos)
    {
      info.update();
    }
  }
  
  public boolean isSilent()
  {
    //return (currentInstrument == null) || ((endTime != -1) && (player.play_position > endTime));
    try
    {
      if ((player.play_position == 0) || (player.play_position >= player.song_duration))
        return true;
      
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
    if (value < lowestPitchFound)
      lowestPitchFound = value;
      
    if (value > highestPitchFound)
      highestPitchFound = value;
    
    value = max(lowerPitch, min(upperPitch, value));
    return map(value, lowerPitch, upperPitch, 0, 1);

    /*
    value -= 1000;
    value /= 500;
    return value;
    */
  }
  
  public int getVolume()
  {
    if (isSilent())
      return 0;
      
    return channel.chanvolfinal;
  }
}

InstrumentData[] allInstruments;
ChannelInfo[] channels;

ArrayList<InstrumentData> usedInstruments = new ArrayList<InstrumentData>();

//Field fieldChannelStep;
Field fieldChannelSilent;
Field fieldChannelPeriod;
Field fieldChannelLog2SamplingRate;

Player player;
Module module;
IBXM ibxm;

float[] samples;
float peak;
float rms;

float lowerPitch;
float upperPitch;
float lowestPitchFound;
float highestPitchFound;

void prepareAnalysis(XML xml)
{
  lowestPitchFound = Float.POSITIVE_INFINITY;
  highestPitchFound = Float.NEGATIVE_INFINITY;
  
  lowerPitch = xml.getFloat("lowerPitch", 1000);
  upperPitch = xml.getFloat("upperPitch", 1500);
  
  player = mod.player;
  module = player.module;
  ibxm = player.ibxm;
  Instrument[] instruments = module.instruments;
  
  usedInstruments.clear();
  
  allInstruments = new InstrumentData[instruments.length];
  for (int i = 0; i < instruments.length; i++)
  {
    Instrument instrument = mod.oldsamples.get(i);
    Sample sample = instrument.samples[0];
    
    InstrumentData instrumentData = new InstrumentData(i + 1, usedInstruments.size(), sample);
    allInstruments[i] = instrumentData;
    
    if (sample.sample_data_length > 0)
      usedInstruments.add(instrumentData);
  }

  channels = new ChannelInfo[module.get_num_channels()];
  for (int i = 0; i < channels.length; i++)
  {
    channels[i] = new ChannelInfo(i, ibxm.channels[i]);
  }

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

    InstrumentData instrument = getInstrumentInstrumentData(note.inst);
    if (instrument.length == 0)
      return;
      
    channel.setCurrentInstrument(instrument);
  }
}

public InstrumentData getInstrumentInstrumentData(int instrument)
{
  return allInstruments[instrument - 1];
}

void processSamples()
{
  byte[] outputBuffer = player.output_buffer;
  if (samples == null)
    samples = new float[outputBuffer.length / 2];
    
  for(int i = 0, s = 0; i < outputBuffer.length;)
  {
    int sample = 0;
    
    sample |= outputBuffer[i++] << 8;   //  if the format is big endian)
    sample |= outputBuffer[i++] & 0xFF; // (reverse these two lines
    
    // normalize to range of +/-1.0f
    samples[s++] = sample / 32768f;
  }
                
  //float lastPeak = peak;
  
  rms = 0f;
  peak = 0f;
  for(float sample : samples) {

      float abs = Math.abs(sample);
      if(abs > peak) {
          peak = abs;
      }

      rms += sample * sample;
  }

  rms = (float) Math.sqrt(rms / samples.length);

  /*
  if (lastPeak > peak) {
    peak = lastPeak * 0.875f;
  }
  */
}

void printInfo()
{
  println("Pitch: " + lowestPitchFound + " to " + highestPitchFound);
  println("Seek position: " + floor(mod.getSeek() / 1000) + " / " + mod.songLength + ", " +
        (floor((mod.getSeek()/1000f)/(mod.songLength)*100)) + "%");
}

void debugDrawPeakAndRms()
{
  background(0);
  stroke(255, 0, 0);
  noFill();
  float r = peak * 500;
  ellipse(width/2, height/2, r, r);
  stroke(0, 255, 0);
  r = rms * 1200;
  ellipse(width/2, height/2, r, r);
}

void debugDrawSamples()
{
  stroke(255);
  noFill();

  float delta = (samples.length-1) / width;
  float centerY = height/2;
  beginShape();
  for (int i = 0; i < samples.length; i++)
  {
    vertex(i * delta, centerY + samples[i] * height);
  }
  endShape();
}

void debugDrawChannelPitch()
{
  float blockHeight = 10;
  for (int i = 0; i < channels.length; i++)
  {
    ChannelInfo channelInfo = channels[i];
    float value = channelInfo.getCurrentStepLogMapped();
    if (channelInfo.isSilent())
      continue;
    
    if (channelInfo.currentInstrument == null)
      continue;
      
    fill(getColor((float)channelInfo.currentInstrument.counter / (usedInstruments.size()-1)));
    
    //print((int)stepLog + " | ");
    //print((int)(stepLog * 10)/10f + " | ");
    
    float rectWidth = width / channels.length;
    float leftX = i * rectWidth;
    float y = (1 - value) * height;
    rect(leftX, y - blockHeight / 2, rectWidth, blockHeight);  
  }
}

void debugDrawChannelInstruments()
{
  float blockHeight = 4;
  float rectWidth = (float)width / channels.length;
  float rectHeight = (float)height / usedInstruments.size();
  for (int i = 0; i < channels.length; i++)
  {
    ChannelInfo channelInfo = channels[i];
    float value = channelInfo.getCurrentStepLogMapped();
    if (channelInfo.isSilent())
      continue;
    
    if (channelInfo.currentInstrument == null)
      continue;
      
    fill(getColor((float)channelInfo.currentInstrument.counter / (usedInstruments.size()-1)));
    
    float x = i * rectWidth;
    float y = channelInfo.currentInstrument.counter * rectHeight;
    rect(x, y, rectWidth, rectHeight);
    
    fill(255);
    y += (1-value) * rectHeight;
    rect(x, y - blockHeight / 2, rectWidth, blockHeight);
  }
}