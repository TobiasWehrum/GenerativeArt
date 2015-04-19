using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class Line2
{
    public Vector2 From { get; set; }
    public Vector2 To { get; set; }

    public Vector2 Center
    {
        get { return (From + To) / 2f; }
    }

    public float Length
    {
        get { return Vector2.Distance(From, To); }
    }

    public Vector2 Delta
    {
        get { return To - From; }
    }

    public Line2(Vector2 from, Vector2 to)
    {
        From = from;
        To = to;
    }
}
