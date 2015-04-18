using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class DecoratorTop : Decorator
{
    [SerializeField] private Transform[] parts;

    public override void Decorate(Animal animal)
    {
        var areaBodyTops = animal.GetComponentsInChildren<AreaBodyTop>();
        foreach (var areaBodyTop in areaBodyTops)
        {
            foreach (var line in areaBodyTop.GetLines())
            {
                AddPart(areaBodyTop.transform, line, parts.RandomElement());
            }
        }
    }

    private void AddPart(Transform parent, Line2 line, Transform partPrefab)
    {
        var part = Instantiate(partPrefab);
        part.position = line.Center;
        part.rotation = Quaternion.Euler(0, 0, line.Delta.GetAngleDeg());
        part.localScale = Vector3.one * line.Length / 2f;
        part.parent = parent;
    }
}
