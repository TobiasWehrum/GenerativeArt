// Taken from http://wiki.unity3d.com/index.php/Tween

using UnityEngine;

public enum EaseType
{
    Linear = 0,
    EaseInQuad = 1,
    EaseOutQuad = 2,
    EaseInOutQuad = 3,
    EaseOutInQuad = 4,
    EaseInCubic = 5,
    EaseOutCubic = 6,
    EaseInOutCubic = 7,
    EaseOutInCubic = 8,
    EaseInQuart = 9,
    EaseOutQuart = 10,
    EaseInOutQuart = 11,
    EaseOutInQuart = 12,
    EaseInQuint = 13,
    EaseOutQuint = 14,
    EaseInOutQuint = 15,
    EaseOutInQuint = 16,
    EaseInSine = 17,
    EaseOutSine = 18,
    EaseInOutSine = 19,
    EaseOutInSine = 20,
    EaseInExpo = 21,
    EaseOutExpo = 22,
    EaseInOutExpo = 23,
    EaseOutInExpo = 24,
    EaseInCirc = 25,
    EaseOutCirc = 26,
    EaseInOutCirc = 27,
    EaseOutInCirc = 28,
    EaseInElastic = 29,
    EaseOutElastic = 30,
    EaseInOutElastic = 31,
    EaseOutInElastic = 32,
    EaseInBack = 33,
    EaseOutBack = 34,
    EaseInOutBack = 35,
    EaseOutInBack = 36,
    EaseInBounce = 37,
    EaseOutBounce = 38,
    EaseInOutBounce = 39,
    EaseOutInBounce = 40
}

public class Ease
{
    // TWEENING EQUATIONS floats -----------------------------------------------------------------------------------------------------
    // (the original equations are Robert Penner's work as mentioned on the disclaimer)

    /**
        * Easing equation float for a simple linear tweening, with no easing.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseNone(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * t / d + b;
    }

    /**
        * Easing equation float for a quadratic (t^2) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInQuad(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * (t /= d) * t + b;
    }

    /**
        * Easing equation float for a quadratic (t^2) easing out: decelerating to zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutQuad(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return -c * (t /= d) * (t - 2) + b;
    }

    /**
        * Easing equation float for a quadratic (t^2) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutQuad(float t, float b = 0f, float c = 1f, float d = 1f)
    {

        if ((t /= d / 2) < 1) return c / 2 * t * t + b;

        return -c / 2 * ((--t) * (t - 2) - 1) + b;
    }

    /**
        * Easing equation float for a quadratic (t^2) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInQuad(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutQuad(t * 2, b, c / 2, d);
        return EaseInQuad((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for a cubic (t^3) easing in: accelerating from zero velocity.
            *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInCubic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * (t /= d) * t * t + b;
    }

    /**
        * Easing equation float for a cubic (t^3) easing out: decelerating from zero velocity.
            *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutCubic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * ((t = t / d - 1) * t * t + 1) + b;
    }

    /**
        * Easing equation float for a cubic (t^3) easing in/out: acceleration until halfway, then deceleration.
            *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutCubic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
        return c / 2 * ((t -= 2) * t * t + 2) + b;
    }

    /**
        * Easing equation float for a cubic (t^3) easing out/in: deceleration until halfway, then acceleration.
            *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInCubic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutCubic(t * 2, b, c / 2, d);
        return EaseInCubic((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
            * Easing equation float for a quartic (t^4) easing in: accelerating from zero velocity.
            *
            * @param t		Current time (in frames or seconds).
            * @param b		Starting value.
            * @param c		Change needed in value.
            * @param d		Expected easing duration (in frames or seconds).
            * @return		The correct value.
            */

    public static float EaseInQuart(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * (t /= d) * t * t * t + b;
    }

    /**
        * Easing equation float for a quartic (t^4) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutQuart(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return -c * ((t = t / d - 1) * t * t * t - 1) + b;
    }

    /**
        * Easing equation float for a quartic (t^4) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutQuart(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if ((t /= d / 2) < 1) return c / 2 * t * t * t * t + b;
        return -c / 2 * ((t -= 2) * t * t * t - 2) + b;
    }

    /**
        * Easing equation float for a quartic (t^4) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInQuart(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutQuart(t * 2, b, c / 2, d);
        return EaseInQuart((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for a quintic (t^5) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInQuint(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * (t /= d) * t * t * t * t + b;
    }

    /**
        * Easing equation float for a quintic (t^5) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutQuint(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
    }

    /**
        * Easing equation float for a quintic (t^5) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutQuint(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if ((t /= d / 2) < 1) return c / 2 * t * t * t * t * t + b;
        return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
    }

    /**
        * Easing equation float for a quintic (t^5) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInQuint(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutQuint(t * 2, b, c / 2, d);
        return EaseInQuint((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for a sinusoidal (sin(t)) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInSine(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return -c * Mathf.Cos(t / d * (Mathf.PI / 2)) + c + b;
    }

    /**
        * Easing equation float for a sinusoidal (sin(t)) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutSine(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * Mathf.Sin(t / d * (Mathf.PI / 2)) + b;
    }

    /**
        * Easing equation float for a sinusoidal (sin(t)) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutSine(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return -c / 2 * (Mathf.Cos(Mathf.PI * t / d) - 1) + b;
    }

    /**
        * Easing equation float for a sinusoidal (sin(t)) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInSine(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutSine(t * 2, b, c / 2, d);
        return EaseInSine((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for an exponential (2^t) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInExpo(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return (t == 0) ? b : c * Mathf.Pow(2, 10 * (t / d - 1)) + b - c * 0.001f;
    }

    /**
        * Easing equation float for an exponential (2^t) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutExpo(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return (t == d) ? b + c : c * 1.001f * (-Mathf.Pow(2, -10 * t / d) + 1) + b;
    }

    /**
        * Easing equation float for an exponential (2^t) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutExpo(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t == 0) return b;
        if (t == d) return b + c;
        if ((t /= d / 2) < 1) return c / 2 * Mathf.Pow(2, 10 * (t - 1)) + b - c * 0.0005f;
        return c / 2 * 1.0005f * (-Mathf.Pow(2, -10 * --t) + 2) + b;
    }

    /**
        * Easing equation float for an exponential (2^t) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInExpo(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutExpo(t * 2, b, c / 2, d);
        return EaseInExpo((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for a circular (sqrt(1-t^2)) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInCirc(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return -c * (Mathf.Sqrt(1 - (t /= d) * t) - 1) + b;
    }

    /**
        * Easing equation float for a circular (sqrt(1-t^2)) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutCirc(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c * Mathf.Sqrt(1 - (t = t / d - 1) * t) + b;
    }

    /**
        * Easing equation float for a circular (sqrt(1-t^2)) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutCirc(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if ((t /= d / 2) < 1) return -c / 2 * (Mathf.Sqrt(1 - t * t) - 1) + b;
        return c / 2 * (Mathf.Sqrt(1 - (t -= 2) * t) + 1) + b;
    }

    /**
        * Easing equation float for a circular (sqrt(1-t^2)) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInCirc(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutCirc(t * 2, b, c / 2, d);
        return EaseInCirc((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for an elastic (exponentially decaying sine wave) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param a		Amplitude.
        * @param p		Period.
        * @return		The correct value.
        */

    public static float EaseInElastic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t == 0) return b;
        if ((t /= d) == 1) return b + c;
        float p = d * .3f;
        float s = 0;
        float a = 0;
        if (a == 0f || a < Mathf.Abs(c))
        {
            a = c;
            s = p / 4;
        }
        else
        {
            s = p / (2 * Mathf.PI) * Mathf.Asin(c / a);
        }
        return -(a * Mathf.Pow(2, 10 * (t -= 1)) * Mathf.Sin((t * d - s) * (2 * Mathf.PI) / p)) + b;
    }

    /**
        * Easing equation float for an elastic (exponentially decaying sine wave) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param a		Amplitude.
        * @param p		Period.
        * @return		The correct value.
        */

    public static float EaseOutElastic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t == 0) return b;
        if ((t /= d) == 1) return b + c;
        float p = d * .3f;
        float s = 0;
        float a = 0;
        if (a == 0f || a < Mathf.Abs(c))
        {
            a = c;
            s = p / 4;
        }
        else
        {
            s = p / (2 * Mathf.PI) * Mathf.Asin(c / a);
        }
        return (a * Mathf.Pow(2, -10 * t) * Mathf.Sin((t * d - s) * (2 * Mathf.PI) / p) + c + b);
    }

    /**
        * Easing equation float for an elastic (exponentially decaying sine wave) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param a		Amplitude.
        * @param p		Period.
        * @return		The correct value.
        */

    public static float EaseInOutElastic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t == 0) return b;
        if ((t /= d / 2) == 2) return b + c;
        float p = d * (.3f * 1.5f);
        float s = 0;
        float a = 0;
        if (a == 0f || a < Mathf.Abs(c))
        {
            a = c;
            s = p / 4;
        }
        else
        {
            s = p / (2 * Mathf.PI) * Mathf.Asin(c / a);
        }
        if (t < 1) return -.5f * (a * Mathf.Pow(2, 10 * (t -= 1)) * Mathf.Sin((t * d - s) * (2 * Mathf.PI) / p)) + b;
        return a * Mathf.Pow(2, -10 * (t -= 1)) * Mathf.Sin((t * d - s) * (2 * Mathf.PI) / p) * .5f + c + b;
    }

    /**
        * Easing equation float for an elastic (exponentially decaying sine wave) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param a		Amplitude.
        * @param p		Period.
        * @return		The correct value.
        */

    public static float EaseOutInElastic(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutElastic(t * 2, b, c / 2, d);
        return EaseInElastic((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param s		Overshoot ammount: higher s means greater overshoot (0 produces cubic easing with no overshoot, and the default value of 1.70158 produces an overshoot of 10 percent).
        * @return		The correct value.
        */

    public static float EaseInBack(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        float s = 1.70158f;
        return c * (t /= d) * t * ((s + 1) * t - s) + b;
    }

    /**
        * Easing equation float for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param s		Overshoot ammount: higher s means greater overshoot (0 produces cubic easing with no overshoot, and the default value of 1.70158 produces an overshoot of 10 percent).
        * @return		The correct value.
        */

    public static float EaseOutBack(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        float s = 1.70158f;
        return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
    }

    /**
        * Easing equation float for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param s		Overshoot ammount: higher s means greater overshoot (0 produces cubic easing with no overshoot, and the default value of 1.70158 produces an overshoot of 10 percent).
        * @return		The correct value.
        */

    public static float EaseInOutBack(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        float s = 1.70158f;
        if ((t /= d / 2) < 1) return c / 2 * (t * t * (((s *= (1.525f)) + 1) * t - s)) + b;
        return c / 2 * ((t -= 2) * t * (((s *= (1.525f)) + 1) * t + s) + 2) + b;
    }

    /**
        * Easing equation float for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @param s		Overshoot ammount: higher s means greater overshoot (0 produces cubic easing with no overshoot, and the default value of 1.70158 produces an overshoot of 10 percent).
        * @return		The correct value.
        */

    public static float EaseOutInBack(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutBack(t * 2, b, c / 2, d);
        return EaseInBack((t * 2) - d, b + c / 2, c / 2, d);
    }

    /**
        * Easing equation float for a bounce (exponentially decaying parabolic bounce) easing in: accelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInBounce(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        return c - EaseOutBounce(d - t, 0, c, d) + b;
    }

    /**
        * Easing equation float for a bounce (exponentially decaying parabolic bounce) easing out: decelerating from zero velocity.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutBounce(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if ((t /= d) < (1 / 2.75f))
        {
            return c * (7.5625f * t * t) + b;
        }
        else if (t < (2 / 2.75f))
        {
            return c * (7.5625f * (t -= (1.5f / 2.75f)) * t + .75f) + b;
        }
        else if (t < (2.5f / 2.75f))
        {
            return c * (7.5625f * (t -= (2.25f / 2.75f)) * t + .9375f) + b;
        }
        else
        {
            return c * (7.5625f * (t -= (2.625f / 2.75f)) * t + .984375f) + b;
        }
    }

    /**
        * Easing equation float for a bounce (exponentially decaying parabolic bounce) easing in/out: acceleration until halfway, then deceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseInOutBounce(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseInBounce(t * 2, 0, c, d) * .5f + b;
        else return EaseOutBounce(t * 2 - d, 0, c, d) * .5f + c * .5f + b;
    }

    /**
        * Easing equation float for a bounce (exponentially decaying parabolic bounce) easing out/in: deceleration until halfway, then acceleration.
        *
        * @param t		Current time (in frames or seconds).
        * @param b		Starting value.
        * @param c		Change needed in value.
        * @param d		Expected easing duration (in frames or seconds).
        * @return		The correct value.
        */

    public static float EaseOutInBounce(float t, float b = 0f, float c = 1f, float d = 1f)
    {
        if (t < d / 2) return EaseOutBounce(t * 2, b, c / 2, d);
        return EaseInBounce((t * 2) - d, b + c / 2, c / 2, d);
    }



    public static Vector3 ChangeVector(float t, Vector3 b, Vector3 c, float d, EaseType easeType)
    {
        float x = 0;
        float y = 0;
        float z = 0;

        if (easeType == EaseType.Linear)
        {
            x = EaseNone(t, b.x, c.x, d);
            y = EaseNone(t, b.y, c.y, d);
            z = EaseNone(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInQuad)
        {
            x = EaseInQuad(t, b.x, c.x, d);
            y = EaseInQuad(t, b.y, c.y, d);
            z = EaseInQuad(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutQuad)
        {
            x = EaseOutQuad(t, b.x, c.x, d);
            y = EaseOutQuad(t, b.y, c.y, d);
            z = EaseOutQuad(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutQuad)
        {
            x = EaseInOutQuad(t, b.x, c.x, d);
            y = EaseInOutQuad(t, b.y, c.y, d);
            z = EaseInOutQuad(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInQuad)
        {
            x = EaseOutInQuad(t, b.x, c.x, d);
            y = EaseOutInQuad(t, b.y, c.y, d);
            z = EaseOutInQuad(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInCubic)
        {
            x = EaseInCubic(t, b.x, c.x, d);
            y = EaseInCubic(t, b.y, c.y, d);
            z = EaseInCubic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutCubic)
        {
            x = EaseOutCubic(t, b.x, c.x, d);
            y = EaseOutCubic(t, b.y, c.y, d);
            z = EaseOutCubic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutCubic)
        {
            x = EaseInOutCubic(t, b.x, c.x, d);
            y = EaseInOutCubic(t, b.y, c.y, d);
            z = EaseInOutCubic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInCubic)
        {
            x = EaseOutInCubic(t, b.x, c.x, d);
            y = EaseOutInCubic(t, b.y, c.y, d);
            z = EaseOutInCubic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInQuart)
        {
            x = EaseInQuart(t, b.x, c.x, d);
            y = EaseInQuart(t, b.y, c.y, d);
            z = EaseInQuart(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutQuart)
        {
            x = EaseOutQuart(t, b.x, c.x, d);
            y = EaseOutQuart(t, b.y, c.y, d);
            z = EaseOutQuart(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutQuart)
        {
            x = EaseInOutQuart(t, b.x, c.x, d);
            y = EaseInOutQuart(t, b.y, c.y, d);
            z = EaseInOutQuart(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInQuart)
        {
            x = EaseOutInQuart(t, b.x, c.x, d);
            y = EaseOutInQuart(t, b.y, c.y, d);
            z = EaseOutInQuart(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInQuint)
        {
            x = EaseInQuint(t, b.x, c.x, d);
            y = EaseInQuint(t, b.y, c.y, d);
            z = EaseInQuint(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutQuint)
        {
            x = EaseOutQuint(t, b.x, c.x, d);
            y = EaseOutQuint(t, b.y, c.y, d);
            z = EaseOutQuint(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutQuint)
        {
            x = EaseInOutQuint(t, b.x, c.x, d);
            y = EaseInOutQuint(t, b.y, c.y, d);
            z = EaseInOutQuint(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInQuint)
        {
            x = EaseOutInQuint(t, b.x, c.x, d);
            y = EaseOutInQuint(t, b.y, c.y, d);
            z = EaseOutInQuint(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInSine)
        {
            x = EaseInSine(t, b.x, c.x, d);
            y = EaseInSine(t, b.y, c.y, d);
            z = EaseInSine(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutSine)
        {
            x = EaseOutSine(t, b.x, c.x, d);
            y = EaseOutSine(t, b.y, c.y, d);
            z = EaseOutSine(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutSine)
        {
            x = EaseInOutSine(t, b.x, c.x, d);
            y = EaseInOutSine(t, b.y, c.y, d);
            z = EaseInOutSine(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInSine)
        {
            x = EaseOutInSine(t, b.x, c.x, d);
            y = EaseOutInSine(t, b.y, c.y, d);
            z = EaseOutInSine(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInExpo)
        {
            x = EaseInExpo(t, b.x, c.x, d);
            y = EaseInExpo(t, b.y, c.y, d);
            z = EaseInExpo(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutExpo)
        {
            x = EaseOutExpo(t, b.x, c.x, d);
            y = EaseOutExpo(t, b.y, c.y, d);
            z = EaseOutExpo(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutExpo)
        {
            x = EaseInOutExpo(t, b.x, c.x, d);
            y = EaseInOutExpo(t, b.y, c.y, d);
            z = EaseInOutExpo(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInExpo)
        {
            x = EaseOutInExpo(t, b.x, c.x, d);
            y = EaseOutInExpo(t, b.y, c.y, d);
            z = EaseOutInExpo(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInCirc)
        {
            x = EaseInCirc(t, b.x, c.x, d);
            y = EaseInCirc(t, b.y, c.y, d);
            z = EaseInCirc(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutCirc)
        {
            x = EaseOutCirc(t, b.x, c.x, d);
            y = EaseOutCirc(t, b.y, c.y, d);
            z = EaseOutCirc(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutCirc)
        {
            x = EaseInOutCirc(t, b.x, c.x, d);
            y = EaseInOutCirc(t, b.y, c.y, d);
            z = EaseInOutCirc(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInCirc)
        {
            x = EaseOutInCirc(t, b.x, c.x, d);
            y = EaseOutInCirc(t, b.y, c.y, d);
            z = EaseOutInCirc(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInElastic)
        {
            x = EaseInElastic(t, b.x, c.x, d);
            y = EaseInElastic(t, b.y, c.y, d);
            z = EaseInElastic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutElastic)
        {
            x = EaseOutElastic(t, b.x, c.x, d);
            y = EaseOutElastic(t, b.y, c.y, d);
            z = EaseOutElastic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutElastic)
        {
            x = EaseInOutElastic(t, b.x, c.x, d);
            y = EaseInOutElastic(t, b.y, c.y, d);
            z = EaseInOutElastic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInElastic)
        {
            x = EaseOutInElastic(t, b.x, c.x, d);
            y = EaseOutInElastic(t, b.y, c.y, d);
            z = EaseOutInElastic(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInBack)
        {
            x = EaseInBack(t, b.x, c.x, d);
            y = EaseInBack(t, b.y, c.y, d);
            z = EaseInBack(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutBack)
        {
            x = EaseOutBack(t, b.x, c.x, d);
            y = EaseOutBack(t, b.y, c.y, d);
            z = EaseOutBack(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutBack)
        {
            x = EaseInOutBack(t, b.x, c.x, d);
            y = EaseInOutBack(t, b.y, c.y, d);
            z = EaseInOutBack(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInBack)
        {
            x = EaseOutInBack(t, b.x, c.x, d);
            y = EaseOutInBack(t, b.y, c.y, d);
            z = EaseOutInBack(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInBounce)
        {
            x = EaseInBounce(t, b.x, c.x, d);
            y = EaseInBounce(t, b.y, c.y, d);
            z = EaseInBounce(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutBounce)
        {
            x = EaseOutBounce(t, b.x, c.x, d);
            y = EaseOutBounce(t, b.y, c.y, d);
            z = EaseOutBounce(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseInOutBounce)
        {
            x = EaseInOutBounce(t, b.x, c.x, d);
            y = EaseInOutBounce(t, b.y, c.y, d);
            z = EaseInOutBounce(t, b.z, c.z, d);
        }
        else if (easeType == EaseType.EaseOutInBounce)
        {
            x = EaseOutInBounce(t, b.x, c.x, d);
            y = EaseOutInBounce(t, b.y, c.y, d);
            z = EaseOutInBounce(t, b.z, c.z, d);
        }


        return new Vector3(x, y, z);
    }

    public static float ChangeFloat(EaseType easeType, float t, float b = 0f, float c = 1f, float d = 1f)
    {
        float value = 0;

        if (easeType == EaseType.Linear)
            value = EaseNone(t, b, c, d);
        else if (easeType == EaseType.EaseInQuad)
            value = EaseInQuad(t, b, c, d);
        else if (easeType == EaseType.EaseOutQuad)
            value = EaseOutQuad(t, b, c, d);
        else if (easeType == EaseType.EaseInOutQuad)
            value = EaseInOutQuad(t, b, c, d);
        else if (easeType == EaseType.EaseOutInQuad)
            value = EaseOutInQuad(t, b, c, d);
        else if (easeType == EaseType.EaseInCubic)
            value = EaseInCubic(t, b, c, d);
        else if (easeType == EaseType.EaseOutCubic)
            value = EaseOutCubic(t, b, c, d);
        else if (easeType == EaseType.EaseInOutCubic)
            value = EaseInOutCubic(t, b, c, d);
        else if (easeType == EaseType.EaseOutInCubic)
            value = EaseOutInCubic(t, b, c, d);
        else if (easeType == EaseType.EaseInQuart)
            value = EaseInQuart(t, b, c, d);
        else if (easeType == EaseType.EaseOutQuart)
            value = EaseOutQuart(t, b, c, d);
        else if (easeType == EaseType.EaseInOutQuart)
            value = EaseInOutQuart(t, b, c, d);
        else if (easeType == EaseType.EaseOutInQuart)
            value = EaseOutInQuart(t, b, c, d);
        else if (easeType == EaseType.EaseInQuint)
            value = EaseInQuint(t, b, c, d);
        else if (easeType == EaseType.EaseOutQuint)
            value = EaseOutQuint(t, b, c, d);
        else if (easeType == EaseType.EaseInOutQuint)
            value = EaseInOutQuint(t, b, c, d);
        else if (easeType == EaseType.EaseOutInQuint)
            value = EaseOutInQuint(t, b, c, d);
        else if (easeType == EaseType.EaseInSine)
            value = EaseInSine(t, b, c, d);
        else if (easeType == EaseType.EaseOutSine)
            value = EaseOutSine(t, b, c, d);
        else if (easeType == EaseType.EaseInOutSine)
            value = EaseInOutSine(t, b, c, d);
        else if (easeType == EaseType.EaseOutInSine)
            value = EaseOutInSine(t, b, c, d);
        else if (easeType == EaseType.EaseInExpo)
            value = EaseInExpo(t, b, c, d);
        else if (easeType == EaseType.EaseOutExpo)
            value = EaseOutExpo(t, b, c, d);
        else if (easeType == EaseType.EaseInOutExpo)
            value = EaseInOutExpo(t, b, c, d);
        else if (easeType == EaseType.EaseOutInExpo)
            value = EaseOutInExpo(t, b, c, d);
        else if (easeType == EaseType.EaseInCirc)
            value = EaseInCirc(t, b, c, d);
        else if (easeType == EaseType.EaseOutCirc)
            value = EaseOutCirc(t, b, c, d);
        else if (easeType == EaseType.EaseInOutCirc)
            value = EaseInOutCirc(t, b, c, d);
        else if (easeType == EaseType.EaseOutInCirc)
            value = EaseOutInCirc(t, b, c, d);
        else if (easeType == EaseType.EaseInElastic)
            value = EaseInElastic(t, b, c, d);
        else if (easeType == EaseType.EaseOutElastic)
            value = EaseOutElastic(t, b, c, d);
        else if (easeType == EaseType.EaseInOutElastic)
            value = EaseInOutElastic(t, b, c, d);
        else if (easeType == EaseType.EaseOutInElastic)
            value = EaseOutInElastic(t, b, c, d);
        else if (easeType == EaseType.EaseInBack)
            value = EaseInBack(t, b, c, d);
        else if (easeType == EaseType.EaseOutBack)
            value = EaseOutBack(t, b, c, d);
        else if (easeType == EaseType.EaseInOutBack)
            value = EaseInOutBack(t, b, c, d);
        else if (easeType == EaseType.EaseOutInBack)
            value = EaseOutInBack(t, b, c, d);
        else if (easeType == EaseType.EaseInBounce)
            value = EaseInBounce(t, b, c, d);
        else if (easeType == EaseType.EaseOutBounce)
            value = EaseOutBounce(t, b, c, d);
        else if (easeType == EaseType.EaseInOutBounce)
            value = EaseInOutBounce(t, b, c, d);
        else if (easeType == EaseType.EaseOutInBounce)
            value = EaseOutInBounce(t, b, c, d);

        return value;
    }
}
