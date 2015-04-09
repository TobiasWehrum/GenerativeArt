using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public abstract class Slot : MonoBehaviourBase
{
    [SerializeField] private float width;
    [SerializeField] private float useChance = 1;

    protected abstract PartType ChoosePartType();

    public float Width { get { return width * transform.lossyScale.x; } }

    public void FillSlot()
    {
        if (UnityEngine.Random.value > useChance)
            return;

        var type = ChoosePartType();
        var partPrefab = PrefabContainer.Instance.GetRandomPrefab(type);
        var newPart = InstantiatePrefab(partPrefab);
        newPart.AttachToSlot(this);
        newPart.transform.parent = transform;
        newPart.Initialize();
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        var endPartOffset = 0.1f;

        var from = transform.position + transform.TransformDirection(Vector3.left * (Width / 2f));
        var to = transform.position + transform.TransformDirection(Vector3.right * (Width / 2f));
        var delta = to - from;
        var perpendicularOffset = new Vector3(-delta.y, delta.x).normalized;

        Gizmos.color = Color.red;
        Gizmos.DrawLine(from, to);
        Gizmos.DrawLine(from - perpendicularOffset * endPartOffset, from + perpendicularOffset * endPartOffset);
        Gizmos.DrawLine(to - perpendicularOffset * endPartOffset, to + perpendicularOffset * endPartOffset);
    }
#endif
}
