using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class PartBase : Part
{
    public override void AttachToSlot(Slot slot)
    {
        throw new InvalidOperationException("PartBase should never attach to a slot since it is the base.");
    }
}
