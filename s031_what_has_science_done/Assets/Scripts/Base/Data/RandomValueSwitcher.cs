using System;
using UnityEngine;
using Random = UnityEngine.Random;

[Serializable]
public class RandomValueSwitcher
{
    [SerializeField] private float min;
    [SerializeField] private float max;
    [SerializeField] private float minChange;
    [SerializeField] private float maxChange;
    [SerializeField] private float changeDelayMin;
    [SerializeField] private float changeDelayMax;

    private bool useUpdate;
    private bool changesPossible;

    public float CurrentValue { get; private set; }
    private float randomMoveSpeedChangeDelay;

    public void Initialize()
    {
        CurrentValue = min;
        ChooseNewRandomMoveSpeed();

        changesPossible = ((minChange > 0) || (maxChange > 0)) && (min != max);
        useUpdate = ((changeDelayMin > 0) || (changeDelayMax > 0)) && changesPossible;
    }

    public void Update(float? deltaTime = null)
    {
        if (deltaTime == null)
            deltaTime = Time.deltaTime;

        if (!useUpdate)
            return;

        randomMoveSpeedChangeDelay -= deltaTime.Value;
        if (randomMoveSpeedChangeDelay <= 0)
        {
            ChangeRandomMoveSpeed();
        }
    }

    public void ChangeRandomMoveSpeed()
    {
        if (!changesPossible)
            return;

        var change = Random.Range(minChange, maxChange);

        if (Random.Range(0f, 1f) < 0.5f)
            change *= -1;

        CurrentValue = Mathf.Clamp(CurrentValue + change, min, max);
        randomMoveSpeedChangeDelay = Random.Range(changeDelayMin, changeDelayMax);
    }

    public void ChooseNewRandomMoveSpeed()
    {
        if (min == max)
            return;

        CurrentValue = Random.Range(min, max);
        randomMoveSpeedChangeDelay = Random.Range(changeDelayMin, changeDelayMax);
    }
}
