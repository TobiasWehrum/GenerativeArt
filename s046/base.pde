boolean loading = false;
String baseSongName = "chiptune.mod";
String settingsXML = "default.xml";
float scaling;
color[] gradient;

int seekSkip = 5000;

void selectXML()
{
  mod.pause();
  
  selectInput("Select config XML", "fileSelected");
}

void fileSelected(File selection)
{
  if (selection != null)
  {
    settingsXML = selection.getAbsolutePath();
    reset();
  }
  else
  {
    audioContinue();
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
  
  String song = xml.getString("song", baseSongName);
  scaling = xml.getFloat("scaling", 3);
  String gradientFilename = xml.getString("gradient", "gradientHue240-480.png");
  boolean gradientReverse = xml.getString("gradientReverse", "false").equals("true");
  
  audioLoad(song);
  
  PImage gradientImage = loadImage(gradientFilename);
  gradient = new color[gradientImage.width];
  for (int i = 0; i < gradientImage.width; i++)
  {
    gradient[i] = gradientImage.get(gradientReverse ? (gradientImage.width - i - 1) : i, 0);
  }

  prepare();
  
  loading = false;

  audioContinue();
}

void keyPressed()
{
  //if (player != null)
  {
    if (keyCode == LEFT)
    {
      audioSkipBackward();
    }
    else if (keyCode == RIGHT)
    {
      audioSkipForward();
    }
    else if (keyCode == UP)
    {
      reset();
    }
    else if (keyCode == DOWN)
    {
      if (isAudioPaused())
      {
        audioContinue();
      }
      else
      {
        audioPause();
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
  if (loading || isAudioPaused() || !isAudioPlaying())
    return;
  
  executeDraw();
}

color getColor(float percent)
{
  return gradient[min((int)(gradient.length * percent), gradient.length-1)];
}