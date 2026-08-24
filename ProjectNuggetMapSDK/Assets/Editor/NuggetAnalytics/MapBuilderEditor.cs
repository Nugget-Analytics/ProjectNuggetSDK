using UnityEngine;
using UnityEditor;
using System.IO;

[CustomEditor(typeof(MapBuilder))]
public class MapBuilderEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        MapBuilder mapBuilder = (MapBuilder)target;
        if (GUILayout.Button("Build Map"))
        {
            BuildMap(mapBuilder);
        }
    }

    private void BuildMap(MapBuilder mapBuilder)
    {
        GameObject parent = mapBuilder.ParentObject;
        if (parent == null)
        {
            EditorUtility.DisplayDialog("Error", "Parent object is not set.", "OK");
            return;
        }

        if (!EditorUtility.DisplayDialog("Confirmation", "Is all of your objects that you want included in your map a child of the object \"MapRoot\"?", "Yes", "No"))
        {
            EditorUtility.DisplayDialog("Error", "Please drag all of your objects under \"MapRoot\" before building again.", "OK");
            return;
        }

        string mapName = mapBuilder.mapName;
        if (string.IsNullOrEmpty(mapName))
        {
            EditorUtility.DisplayDialog("Error", "Map name cannot be empty.", "OK");
            return;
        }

        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            EditorUtility.DisplayDialog("Error", "You must set BuildTarget to Android in the Build Settings window to build your map.", "OK");
            return;
        }

        GameObject[] allObjects = GameObject.FindObjectsOfType<GameObject>();
        int spawnCount = 0;
        bool hasExitButton = false;
        bool exitButtonValid = false;

        foreach (GameObject obj in allObjects)
        {
            if (obj.name == "SpawnPosition")
                spawnCount++;
            if (obj.name == "ExitButton")
            {
                hasExitButton = true;
                BoxCollider bc = obj.GetComponent<BoxCollider>();
                if (bc != null && bc.isTrigger)
                    exitButtonValid = true;
            }
        }

        if (spawnCount == 0)
        {
            EditorUtility.DisplayDialog("Error", "You do not have a 'SpawnPosition' in your scene, drag one from Assets/MapPrefabs or if you do have one then rename it to SpawnPosition.", "OK");
            return;
        }
        if (spawnCount > 1)
        {
            EditorUtility.DisplayDialog("Error", "You can not have more than one SpawnPosition in a map!", "OK");
            return;
        }

        if (!hasExitButton || !exitButtonValid)
        {
            EditorUtility.DisplayDialog("Error", "You do not have a 'ExitButton' in your scene, drag one from Assets/MapPrefabs or if you do have one then rename it to ExitButton.", "OK");
            return;
        }

        string prefabFolder = "Assets/MapPrefabs";
        string prefabPath = Path.Combine(prefabFolder, mapName + ".prefab");
        prefabPath = AssetDatabase.GenerateUniqueAssetPath(prefabPath);

        GameObject prefab = PrefabUtility.SaveAsPrefabAsset(parent, prefabPath);
        if (prefab == null)
        {
            EditorUtility.DisplayDialog("Error", "Failed to create prefab from parent object.", "OK");
            return;
        }

        AssetImporter prefabImporter = AssetImporter.GetAtPath(prefabPath);
        if (prefabImporter == null)
        {
            EditorUtility.DisplayDialog("Error", "Failed to get importer for prefab.", "OK");
            return;
        }
        prefabImporter.assetBundleName = mapName;

        string outFolder = "Assets/AssetBundles";
        BuildPipeline.BuildAssetBundles(outFolder, BuildAssetBundleOptions.None, BuildTarget.Android);

        prefabImporter.assetBundleName = null;

        AssetDatabase.DeleteAsset(prefabPath);

        AssetDatabase.Refresh();

        EditorUtility.DisplayDialog(
            "Congratulations!",
            "You have built your map! You can share this in the Discord to get it added to Project Nugget!\n\n" +
            "Remember: scripts are not included in maps, so any code you may have added will NOT work at this time.\n\n" +
            "Exception: MapSurfaceOverride components DO work - attach one to an object with a collider and set its Surface ID (hand tap sound) and Velocity Multiplier.\n\n" +
            "MapObjectTrigger components also work - attach one to any object to make a pressable button that enables/disables/toggles the objects in its lists (it needs a Box Collider with Is Trigger on, sized to where hands should press). Assign its Button Renderer plus Pressed/Unpressed Materials for visual press feedback.",
            "OK"
        );

        string pathBundle = Path.Combine(outFolder, mapName);
        if (File.Exists(pathBundle))
        {
            EditorUtility.RevealInFinder(pathBundle);
        }
    }
}