using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using UnityEngine;
using Random = System.Random;

public static class GeneralHelper
{
    public static T RandomElement<T>(this T[] array)
    {
        var index = UnityEngine.Random.Range(0, array.Length);
        return array[index];
    }

    public static T RandomElement<T>(this List<T> list)
    {
        var index = UnityEngine.Random.Range(0, list.Count);
        return list[index];
    }

    public static Vector2 RandomPosition(this Rect rect, float shrinkDistance = 0f)
    {
        return new Vector2(UnityEngine.Random.Range(rect.xMin + shrinkDistance, rect.xMax - shrinkDistance), UnityEngine.Random.Range(rect.yMin + shrinkDistance, rect.yMax - shrinkDistance));
    }

    public static Rect RandomSubRect(this Rect rect, float width, float height)
    {
        width = Mathf.Min(rect.width, width);
        height = Mathf.Min(rect.height, height);

        var halfWidth = width / 2f;
        var halfHeight = height / 2f;

        var centerX = UnityEngine.Random.Range(rect.xMin + halfWidth, rect.xMax - halfWidth);
        var centerY = UnityEngine.Random.Range(rect.yMin + halfHeight, rect.yMax - halfHeight);

        return new Rect(centerX - halfWidth, centerY - halfHeight, width, height);
    }

    public static Vector2 Clamp(this Rect rect, Vector2 vector, float extendDistance = 0f)
    {
        return new Vector2(Mathf.Clamp(vector.x, rect.xMin - extendDistance, rect.xMax + extendDistance),
                           Mathf.Clamp(vector.y, rect.yMin - extendDistance, rect.yMax + extendDistance));
    }

    public static Vector3 Clamp(this Rect rect, Vector3 vector, float extendDistance = 0f)
    {
        return new Vector3(Mathf.Clamp(vector.x, rect.xMin - extendDistance, rect.xMax + extendDistance),
                           Mathf.Clamp(vector.y, rect.yMin - extendDistance, rect.yMax + extendDistance),
                           vector.z);
    }

    public static void Swap<T>(ref T a, ref T b)
    {
        var temp = a;
        a = b;
        b = temp;
    }

    public static void Shuffle<T>(this List<T> list)
    {
        var count = list.Count;
        for (int i1 = 0; i1 < count; i1++)
        {
            var i2 = UnityEngine.Random.Range(0, count);
            var element = list[i1];
            list[i1] = list[i2];
            list[i2] = element;
        }
    }

    public static string GetElementString(this XmlNode xmlNode, string name, string defaultValue = "")
    {
        var element = xmlNode[name];
        if (element == null)
            return defaultValue;

        return element.InnerText;
    }

    public static int GetElementInt(this XmlNode xmlNode, string name, int defaultValue = 0)
    {
        var element = xmlNode[name];
        if (element == null)
            return defaultValue;

        return int.Parse(element.InnerText);
    }

    public static float GetElementFloat(this XmlNode xmlNode, string name, float defaultValue = 0)
    {
        var element = xmlNode[name];
        if (element == null)
            return defaultValue;

        return float.Parse(element.InnerText);
    }

    public static string GetAttributeString(this XmlNode xmlNode, string name, string defaultValue = "")
    {
        var attribute = xmlNode.Attributes[name];
        if (attribute == null)
            return defaultValue;

        return attribute.Value;
    }

    public static int GetAttributeInt(this XmlNode xmlNode, string name, int defaultValue = 0)
    {
        var attribute = xmlNode.Attributes[name];
        if (attribute == null)
            return defaultValue;

        return int.Parse(attribute.Value);
    }

    public static int? GetAttributeIntNullable(this XmlNode xmlNode, string name, int? defaultValue = null)
    {
        var attribute = xmlNode.Attributes[name];
        if (attribute == null)
            return defaultValue;

        return int.Parse(attribute.Value);
    }

    public static float GetAttributeFloat(this XmlNode xmlNode, string name, float defaultValue = 0)
    {
        var attribute = xmlNode.Attributes[name];
        if (attribute == null)
            return defaultValue;

        return float.Parse(attribute.Value);
    }

    public static float? GetAttributeFloatNullable(this XmlNode xmlNode, string name, float? defaultValue = null)
    {
        var attribute = xmlNode.Attributes[name];
        if (attribute == null)
            return defaultValue;

        return float.Parse(attribute.Value);
    }

    public static bool GetAttributeBool(this XmlNode xmlNode, string name, bool defaultValue = false)
    {
        var attribute = xmlNode.Attributes[name];
        if (attribute == null)
            return defaultValue;

        return bool.Parse(attribute.Value);
    }

    public static string ColorRGBToString(Color color)
    {
        return String.Format("RGB({0}, {1}, {2})", color.r, color.g, color.b);
    }

    public static string ToOneLineString<T>(this IEnumerable<T> list, string separator = ", ", string encapsulate = "\"")
    {
        var result = "";
        foreach (var element in list)
        {
            if (result.Length > 0)
                result += separator;

            result += encapsulate + element + encapsulate;
        }

        return result;
    }

    // http://wiki.unity3d.com/index.php?title=HexConverter
    public static Color HexToColor(string hex)
    {
        byte r = byte.Parse(hex.Substring(0, 2), System.Globalization.NumberStyles.HexNumber);
        byte g = byte.Parse(hex.Substring(2, 2), System.Globalization.NumberStyles.HexNumber);
        byte b = byte.Parse(hex.Substring(4, 2), System.Globalization.NumberStyles.HexNumber);
        return new Color32(r, g, b, 255);
    }
}
