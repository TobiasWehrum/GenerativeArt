using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public abstract class Part : MonoBehaviourBase
{
    [SerializeField] private PartType type;

    public PartType Type { get { return type; } }

    public abstract void AttachToSlot(Slot slot);

    public void Initialize()
    {
        foreach (var slot in GetComponentsInChildren<Slot>())
        {
            slot.FillSlot();
        }
    }
}
