using UnityEngine;

public class MapBuilder : MonoBehaviour
{
    public string mapName = "MyMap";
    private GameObject parentObject;

    void Reset()
    {
        parentObject = gameObject;
    }

    void OnValidate()
    {
        if (parentObject == null)
            parentObject = gameObject;
    }

    public GameObject ParentObject => parentObject;
}