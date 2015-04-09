using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[Serializable]
public class BetweenFloat
{
    [SerializeField] private float from;
    [SerializeField] private float to;

    public float From { get { return from; } }
    public float To { get { return to; } }
    public float Range { get { return to - from; } }

    public float Random { get { return UnityEngine.Random.Range(from, to); } }

    public BetweenFloat()
    {
    }

    public BetweenFloat(float @from, float to)
    {
        this.@from = @from;
        this.to = to;
    }

    public float Lerp(float t)
    {
        return Mathf.Lerp(from, to, t);
    }
}
