using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class Countdown
{
    public Func<float> CalculateCountdownLength { get; private set; }
    public float TimeLeft { get; private set; }
    public float TotalTime { get; private set; }

    private float startValue;

    public Countdown(Func<float> calculateCountdownLength, float? startValue = null)
    {
        if (startValue == null)
            startValue = calculateCountdownLength();

        TimeLeft = startValue.Value;
        TotalTime = TimeLeft;
        CalculateCountdownLength = calculateCountdownLength;

        this.startValue = startValue.Value;
    }

    public Countdown(float startValue)
    {
        TimeLeft = startValue;
        TotalTime = TimeLeft;
        CalculateCountdownLength = null;

        this.startValue = startValue;
    }

    public IEnumerator CountdownToZeroEnumerator(bool pauseThisFrame)
    {
        if (pauseThisFrame)
            yield return null;

        while (!Update())
        {
            yield return null;
        }
    }

    public bool Update()
    {
        return InternalUpdate(null);
    }

    public bool Update(float deltaTime)
    {
        return InternalUpdate(deltaTime);
    }

    private bool InternalUpdate(float? deltaTime)
    {
        ReachedZeroThisFrame = false;

        if (deltaTime == null)
            deltaTime = Time.deltaTime;

        if (TimeLeft < 0)
            Loop();

        TimeLeft -= deltaTime.Value;
        if (TimeLeft <= 0)
        {
            ReachedZeroThisFrame = true;
        }

        return ReachedZeroThisFrame;
    }

    public void Reset()
    {
        if (CalculateCountdownLength == null)
        {
            TimeLeft = startValue;
        }
        else
        {
            TimeLeft = CalculateCountdownLength();
        }

        TotalTime = TimeLeft;
    }

    public void Reset(float timeLeft)
    {
    	startValue = timeLeft;
        TimeLeft = timeLeft;
        TotalTime = timeLeft;
    }

    private void Loop()
    {
        if (CalculateCountdownLength != null)
        {
            Continue(CalculateCountdownLength());
        }
        else
        {
            Continue(startValue);
        }
    }

    public void Continue(float timeLeft)
    {
        TimeLeft += timeLeft;
        TotalTime = timeLeft;
    }

    public bool ReachedZeroThisFrame { get; private set; }
    public bool ReachedZero { get { return TimeLeft <= 0; } }

    public float TimePassed { get { return TotalTime - TimeLeft; } }

    public float Percent
    {
        get
        {
            if (TotalTime == 0)
                return 1f;

            return 1 - Mathf.Clamp01(TimeLeft / TotalTime);
        }
    }
}
