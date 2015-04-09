using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[Serializable]
public class BetweenInt
{
    [SerializeField] private int from;
    [SerializeField] private int to;

    public int From { get { return from; } }
    public int To { get { return to; } }
    public int Range { get { return to - from; } }

    public int Random { get { return UnityEngine.Random.Range(from, to); } }

    public BetweenInt()
    {
    }

    public BetweenInt(int from, int to)
    {
        this.from = from;
        this.to = to;
    }
}
