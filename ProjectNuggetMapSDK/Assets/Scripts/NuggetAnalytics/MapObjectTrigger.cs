using UnityEngine;

public class MapObjectTrigger : MonoBehaviour
{
	public Material pressedMaterial;

	public Material unpressedMaterial;

	public MeshRenderer buttonRenderer;

	[Header("Trigger")]

	public GameObject[] objectsToEnable;

	public GameObject[] objectsToDisable;

	public bool toggleMode;
}
