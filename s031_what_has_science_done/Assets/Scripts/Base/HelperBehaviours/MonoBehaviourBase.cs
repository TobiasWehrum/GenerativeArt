using UnityEngine;

public class MonoBehaviourBase : MonoBehaviour
{
    public T GetComponentByInterface<T>() where T : class
    {
        return UnityHelper.GetComponentByInterface<T>(this);
    }

    public T[] GetComponentsByInterface<T>() where T : class
    {
        return UnityHelper.GetComponentsByInterface<T>(this);
    }

    public T GetComponentInChildrenByInterface<T>() where T : class
    {
        return UnityHelper.GetComponentInChildrenByInterface<T>(this);
    }

    public T[] GetComponentsInChildrenByInterface<T>() where T : class
    {
        return UnityHelper.GetComponentsInChildrenByInterface<T>(this);
    }

    public static GameObject InstantiatePrefabGameObject(GameObject prefab)
    {
        return UnityHelper.InstantiatePrefabGameObject(prefab);
    }

    public static GameObject InstantiatePrefabGameObject(GameObject prefab, Vector3 position, Quaternion rotation = default(Quaternion))
    {
        return UnityHelper.InstantiatePrefabGameObject(prefab, position, rotation);
    }

    public static T InstantiatePrefab<T>(T prefab) where T : Component
    {
        return UnityHelper.InstantiatePrefab(prefab);
    }

    public static T InstantiatePrefab<T>(T prefab, Vector3 position, Quaternion rotation = default(Quaternion)) where T : Component
    {
        return UnityHelper.InstantiatePrefab(prefab, position, rotation);
    }
}
