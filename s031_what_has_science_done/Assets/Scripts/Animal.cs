using UnityEngine;
using System.Collections;
using System.Linq;

public class Animal : MonoBehaviourBase
{
    [SerializeField] private PartType[] startingTypes;

    private void Awake()
    {
        var startingType = startingTypes.RandomElement();
        var partPrefab = PrefabContainer.Instance.GetRandomPrefab(startingType);
        var startPart = InstantiatePrefab(partPrefab);
        startPart.transform.parent = transform;
        startPart.Initialize();

        var sprites = GetComponentsInChildren<SpriteRenderer>();
        var completeBounds = sprites[0].bounds;
        foreach (var sprite in sprites.Skip(1))
        {
            completeBounds.Encapsulate(sprite.bounds);
        }

        var maxY = Camera.main.orthographicSize;
        var maxX = maxY * Camera.main.aspect;
        //var biggerCurrentY = Mathf.Max(Mathf.Abs(completeBounds.max.y), Mathf.Abs(completeBounds.min.y));
        var scale = Mathf.Min(maxY / completeBounds.extents.y, maxX / completeBounds.extents.x, 1f);

        transform.localScale = Vector3.one * scale;

        //transform.position = new Vector3(transform.position.x - completeBounds.center.x, 0, 0);
        transform.position = -completeBounds.center * scale;

        //completeBounds.center = transform.position;
    }
}
