using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class DecoratorWings : Decorator
{
    [SerializeField] private Transform[] wings;
    [SerializeField] private AnimationCurve sizeDistribution;

    public override void Decorate(Animal animal)
    {
        var areaBodyTops = animal.GetComponentsInChildren<AreaBodyTop>().ToList();
        if (areaBodyTops.Count == 0)
            return;

        var lines = areaBodyTops.SelectMany(area => area.GetLines()).ToList();
        var center = new Vector2();
        foreach (var line in lines)
            center += line.Center;
        center /= lines.Count;

        var averageLineLength = lines.Average(line => line.Length);
        var minX = lines.Min(line => line.From.x);
        var maxX = lines.Max(line => line.To.x);
        var fullLengthX = maxX - minX;

        if (averageLineLength > fullLengthX)
            averageLineLength = fullLengthX;

        var wingsLength = Mathf.Lerp(averageLineLength, fullLengthX, sizeDistribution.Evaluate(UnityEngine.Random.value));

        var wingsPrefab = wings.RandomElement();
        var wingsInstance = InstantiatePrefab(wingsPrefab, center);
        wingsInstance.localScale = Vector3.one * (wingsLength / 2f);
        wingsInstance.parent = animal.transform;
    }
}
