class Palette
{
  ArrayList<Integer> colors = new ArrayList<Integer>();
  ArrayList<Float> widths = new ArrayList<Float>();
  float totalWidth = 0;
  String name;
  
  void addColor(color c, float w)
  {
    colors.add(c);
    widths.add(w);
    totalWidth += w;
  }
  
  color getPercent(float value)
  {
    if (value <= 0)
      return colors.get(0);
      
    if (value >= 1)
      return colors.get(colors.size()-1);
      
    int lowerIndex = floor(value * (colors.size() - 1));
    float percent = value * (colors.size() - 1) - lowerIndex;
    
    color c1 = colors.get(lowerIndex);
    color c2 = colors.get(lowerIndex+1);
    
    return lerpColor(c1, c2, percent);
  }
  
  color randomColor()
  {
    if (colors.size() == 0)
      return color(0, 0, 0, 0);
    
    float value = random(totalWidth);
    int index = 0;
    while ((index + 1) < colors.size())
    {
      float currentWidth = widths.get(index);
      if (value < currentWidth)
        break;

      value -= widths.get(index);
      index++;
    }
    
    return colors.get(index);
  }
}

ArrayList<Palette> loadPalettes(String filename, boolean useWidths)
{
  ArrayList<Palette> palettes = new ArrayList<Palette>();

  XML xml = loadXML(filename + ".xml");
  XML[] children = xml.getChildren("palette");
  for (XML child : children)
  {
    Palette palette = new Palette();
    XML[] xcolors = child.getChild("colors").getChildren("hex");
    String[] widths = null;
    if (useWidths)
      widths = child.getChild("colorWidths").getContent().split(",");
    String title = child.getChild("title").getContent();
    palette.name = title;//.substring(10, title.length()-10-3);
    int i = 0;
    for(XML xcolor : xcolors)
    {
      color c = unhex("FF" + xcolor.getContent());
      
      float w = 1;
      if (useWidths)
        w = Float.parseFloat(widths[i]);
        
      i++;
      palette.addColor(c, w);
    }
    
    palettes.add(palette);
  }
  
  return palettes;
}