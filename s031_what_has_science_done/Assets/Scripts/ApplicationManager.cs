using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ApplicationManager : MonoBehaviourBase
{
    [SerializeField] private Animal animalPrefab;

    private Animal animal;

    private void Awake()
    {
        animal = CreateAnimal();
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Destroy(animal.gameObject);
            animal = CreateAnimal();
        }
    }

    private Animal CreateAnimal()
    {
        return InstantiatePrefab(animalPrefab);
    }
}
