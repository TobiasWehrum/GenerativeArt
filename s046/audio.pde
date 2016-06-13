import crayolon.portamod.*;

PortaMod mod;

void audioSetup()
{
  mod = new PortaMod(this);
}

void audioLoad(String song)
{
  mod.doModLoad(song, true, 64);
  mod.setSongloop(false);
}

void audioContinue()
{
  mod.play();
}

void audioPause()
{
  mod.pause();
}

void audioSkipBackward()
{
  mod.setSeek(Math.max(mod.getSeek() - seekSkip, 0));
}

void audioSkipForward()
{
  mod.setSeek(mod.getSeek() + seekSkip);
}

boolean isAudioPaused()
{
  return mod.paused;
}

boolean isAudioPlaying()
{
  return mod.playing;
}