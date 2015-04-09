using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class MultiSlot : Slot
{
    [SerializeField] private PartType[] types;

    protected override PartType ChoosePartType()
    {
        return types.RandomElement();
    }
}
