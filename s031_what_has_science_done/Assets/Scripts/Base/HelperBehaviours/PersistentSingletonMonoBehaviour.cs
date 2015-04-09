using UnityEngine;

public class PersistentSingletonMonoBehaviour<T> : MonoBehaviourBase where T : PersistentSingletonMonoBehaviour<T>
{
    private static T instance;
    protected bool InstanceExists { get { return instance != null; } }
    public static T Instance { get { return instance; } }

    private bool firstLoad;

    protected virtual void Awake()
    {
        if (InstanceExists)
        {
            Destroy(gameObject);
            return;
        }

        instance = (T) this;
        DontDestroyOnLoad(gameObject);
        OnFirstLoad();
        OnFirstLoadOrSwitch();

        firstLoad = true;
    }

    protected virtual void OnLevelWasLoaded()
    {
        if (firstLoad)
            return;

        if (Instance == this)
        {
            OnSceneSwitched();
            OnFirstLoadOrSwitch();
        }
    }

    protected virtual void Start()
    {
        firstLoad = false;
    }

    protected virtual void OnFirstLoad()
    {
    }

    protected virtual void OnSceneSwitched()
    {
    }

    protected virtual void OnFirstLoadOrSwitch()
    {
    }
}
