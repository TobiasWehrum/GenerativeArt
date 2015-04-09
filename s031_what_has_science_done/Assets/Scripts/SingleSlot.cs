using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class SingleSlot : Slot
{
    [SerializeField] private PartType type;

    protected override PartType ChoosePartType()
    {
        return type;
    }
}
