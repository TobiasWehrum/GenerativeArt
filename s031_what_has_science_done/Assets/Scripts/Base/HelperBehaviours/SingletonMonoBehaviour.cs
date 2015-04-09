using System;
using UnityEngine;

public class SingletonMonoBehaviour<T> : MonoBehaviourBase where T : SingletonMonoBehaviour<T>
{
    private static T instance;

    public static T Instance
    {
        get
        {
            if (instance == null)
            {
                UpdateInstance();
            }

            return instance;
        }
    }

    private static void UpdateInstance()
    {
        var instances = (T[]) FindObjectsOfType(typeof (T));
        if (instances.Length == 1)
        {
            instance = instances[0];
        }
        else if (instances.Length == 0)
        {
            Debug.Log("Requested singleton of type " + typeof (T).Name + " not found.");
        }
        else
        {
            Debug.Log("Requested singleton of type " + typeof (T).Name + " has " + instances.Length + "instances.");
        }
    }
}
