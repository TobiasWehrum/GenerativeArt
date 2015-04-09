using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System.Collections;

public class PrefabContainer : SingletonMonoBehaviour<PrefabContainer>
{
    [SerializeField] private Part[] allParts;

    private Dictionary<PartType, List<Part>> partsByType;

    private void Awake()
    {
        partsByType = new Dictionary<PartType, List<Part>>();
        foreach (var part in allParts)
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
}
