using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class PartAutoSlotted : Part
{
    public override void AttachToSlot(Slot slot)
    {
        var slotWidth = slot.Width;
        transform.position = slot.transform.position;
        transform.rotation = slot.transform.rotation;
        transform.localScale = Vector3.one * slotWidth / 2f;
    }
}
