using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public static class LINQExtensions
{
    public static T FirstByGeneratedValue<T, U>(this IEnumerable<T> list, Func<T, U> valueConverter, Comparison<U> valueComparer, Predicate<T> predicateElement = null, Predicate<U> predicateValue = null)
    {
        bool isFirstElement = true;
        T bestElement = default(T);
        U bestValue = default(U);

        foreach (var element in list)
        {
            if ((predicateElement != null) && (!predicateElement(element)))
                continue;

            var value = valueConverter(element);

            if ((predicateValue != null) && (!predicateValue(value)))
                continue;

            if (isFirstElement || (valueComparer(value, bestValue) < 0))
            {
                isFirstElement = false;
                bestElement = element;
                bestValue = value;
            }
        }

        return bestElement;
    }

    public static T Nearest<T>(this IEnumerable<T> list, Vector3 referencePoint, Predicate<T> predicateElement = null, Predicate<float> predicateValue = null) where T : Component
    {
        return list.FirstByGeneratedValue(component => Vector3.Distance(component.transform.position, referencePoint), (fA, fB) => fA.CompareTo(fB), predicateElement, predicateValue);
    }
}
