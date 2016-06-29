class PathPoint
{
  public PVector position;
  public PVector tangent;
  public boolean tangentLocked;
  public PathPoint next;
  public PathPoint previous;
  public color c;
  public float depth;
  
  public PathPoint(PVector position)
  {
    this.position = new PVector(position.x, position.y);
    tangentLocked = false;
  }
  
  public PathPoint(PVector position, PVector tangent)
  {
    this.position = new PVector(position.x, position.y);
    this.tangent = tangent;
    tangentLocked = true;
  }
  
  public void setNextPoint(PathPoint next)
  {
    this.next = next;
    updateTangent();
  }
  
  public void setPreviousPoint(PathPoint previous)
  {
    this.previous = previous;
    updateTangent();
  }
  
  private void updateTangent()
  {
    if (tangentLocked)
      return;
    
    PVector direction1 = (previous != null) ? PVector.sub(position, previous.position) : null;
    PVector direction2 = (next != null) ? PVector.sub(next.position, position) : null;
    
    if (direction1 == null && direction2 == null)
    {
      tangent = null;
      return;
    }
    
    if (direction2 == null)
    {
      tangent = direction1;
    }
    else if (direction1 == null)
    {
      tangent = direction2;
    }
    else
    {
      direction1.normalize();
      direction2.normalize();
      tangent = PVector.add(direction1, direction2);
    }
    
    tangent.normalize();
  }
  
  void getTangentPoint(boolean forward, float distance, PVector out)
  {
    if (tangent == null)
    {
      out.x = position.x;
      out.y = position.y;
    }
    
    float direction = forward ? 1 : -1;
    out.x = position.x + direction * distance * -  tangent.y;
    out.y = position.y + direction * distance * tangent.x;
  }
}

class Path
{
  ArrayList<PathPoint> points = new ArrayList<PathPoint>();
  
  public PathPoint addPoint(PVector point)
  {
    return addPoint(new PathPoint(point));
  }

  public PathPoint addPoint(PVector point, PVector tangent)
  {
    return addPoint(new PathPoint(point, tangent));
  }
  
  public PathPoint addPoint(PathPoint point)
  {
    if (points.size() > 0)
    {
      PathPoint previousPoint = points.get(points.size() - 1);
      previousPoint.setNextPoint(point);
      point.setPreviousPoint(previousPoint);
    }
    
    points.add(point);
    return point;
  }
}