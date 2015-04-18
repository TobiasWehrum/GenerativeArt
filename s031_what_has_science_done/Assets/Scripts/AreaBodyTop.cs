using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[RequireComponent(typeof(EdgeCollider2D))]
public class AreaBodyTop : MonoBehaviourBase
{
    public IEnumerable<Line2> GetLines()
    {
        var edgeCollider = GetComponent<EdgeCollider2D>();
        for (var i = 0; i < edgeCollider.pointCount - 1; i++)
        {
            yield return new Line2(transform.TransformPoint(edgeCollider.points[i]),
                                   transform.TransformPoint(edgeCollider.points[i + 1]));
        }
    }
}
