import beads.*;
import org.jaudiolibs.beads.*;

AudioContext ac;
Clock clock;
MusicalBead bead;

void setup()
{
  frameRate(200);
  size(720, 720);
  ac = new AudioContext();
  reset();
}

void draw()
{
}

void mousePressed()
{
  bead.reset();
}

void reset()
{
  ac.stop();
  
  if (clock != null)
  {
    ac.out.removeDependent(clock);
    clock = null;
  }
  
  clock = new Clock(ac, 700);
  bead = new MusicalBead();
  clock.addMessageListener(bead);
  ac.out.addDependent(clock);
  ac.start();
}

class MusicalBead extends Bead
{
  int drum1;
  int drum2;
  int note1A;
  int note1B;
  int note1C;
  float note1D;
  float note1E;
  float note1F;
  float note1G;
  float note1H;
  
  public MusicalBead()
  {
    reset();
  }
  
  void reset()
  {
    drum1 = 2 * (int)random(1, 5);
    drum2 = 2 * drum1;
    
    note1A = 2 * (int)random(2, 3);
    note1B = 12;
    note1C = 5;
    note1D = random(1);
    note1E = random(0.1);
    note1F = random(50);
    note1G = random(400);
    note1H = random(1);
  }
  
  public void messageReceived(Bead message)
  {
    Clock c = (Clock)message;
    if (c.getCount() % note1A == 0)
    {
      if (random(1) > note1H)
      {
        //choose some nice frequencies
        float pitch = Pitch.forceToScale((int)random(note1B), Pitch.dorian);
        float freq = Pitch.mtof(pitch + (int)random(note1C) * 12 + 32);
        WavePlayer wp = new WavePlayer(ac, freq, Buffer.SQUARE);
        Gain g = new Gain(ac, 1, new Envelope(ac, 0));
        g.addInput(wp);
        Panner p = new Panner(ac, note1D);
        p.addInput(g);
        ac.out.addInput(p);
        ((Envelope)g.getGainEnvelope()).addSegment(note1E, note1F);
        ((Envelope)g.getGainEnvelope()).addSegment(0, note1G, new KillTrigger(p));
      }
    }
    if (c.getCount() % drum2 == 0)
    {
      Noise n = new Noise(ac);
      Gain g = new Gain(ac, 1, new Envelope(ac, 0.05));
      g.addInput(n);
      Panner p = new Panner(ac, 0.5);
      p.addInput(g);
      ac.out.addInput(p);
      ((Envelope)g.getGainEnvelope()).addSegment(0, 50, new KillTrigger(p));
    }
    else if (c.getCount() % drum1 == 0)
    {
      Noise n = new Noise(ac);
      Gain g = new Gain(ac, 1, new Envelope(ac, 0.05));
      g.addInput(n);
      Panner p = new Panner(ac, 0.5);
      p.addInput(g);
      ac.out.addInput(p);
      ((Envelope)g.getGainEnvelope()).addSegment(0, 100, new KillTrigger(p));
    }
  }
}