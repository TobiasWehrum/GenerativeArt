using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System.Collections;

public class PrefabContainer : SingletonMonoBehaviour<PrefabContainer>
{
    [SerializeField] private Part[] debugOverride;
    [SerializeField] private int debugOverrideMultiplicator = 1;
    [SerializeField] private Part[] allParts;
    [SerializeField] private Decorator[] allDecorators;

    private Dictionary<PartType, List<Part>> partsByType;

    private void Awake()
    {
        partsByType = new Dictionary<PartType, List<Part>>();
        AddToPartsByType(allParts);

        for (int i = 0; i < debugOverrideMultiplicator; i++)
        {
            AddToPartsByType(debugOverride);
        }
    }

    private void AddToPartsByType(Part[] parts)
    {
        foreach (var part in parts)
        {
            if (!partsByType.ContainsKey(part.Type))
                partsByType[part.Type] = new List<Part>();

            partsByType[part.Type].Add(part);
        }
    }

    public Part GetRandomPrefab(PartType type)
    {
        return partsByType[type].RandomElement();
    }

    public Decorator GetRandomDecorator()
    {
        return allDecorators.RandomElement();
    }
}
