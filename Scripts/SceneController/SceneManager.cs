using UnityEngine;
using System.Collections;

public class SceneManager : MonoBehaviour
{

    public float planetRotSpeed = 1.0f;
    public float sunRotSpeed = 1.0f;
    public Transform sun;
    public Transform[] planets = new Transform[9];
    public float Height = 5;

    void Start()
    {
        Height = PlanetData.PlanetDiameter;
    }

    /*   void Update()
       {
           foreach (Transform planet in planets)
               planet.Rotate(new Vector3(0, planetRotSpeed * Time.deltaTime, 0));
           if (Input.GetKey(KeyCode.Z))
               sun.Rotate(new Vector3(0, sunRotSpeed * Time.deltaTime, 0));
           else if (Input.GetKey(KeyCode.C))
               sun.Rotate(new Vector3(0, -sunRotSpeed * Time.deltaTime, 0));
       }*/

    void OnGUI()
    {
        GUILayout.BeginArea(new Rect(50, 50, 400, 400));
        GUILayout.Label("~ - Toggle help");
        GUILayout.Label("Camera Height", GUILayout.ExpandWidth(false));
        Height = GUILayout.HorizontalSlider(Height, PlanetData.MinPlanetRadius, PlanetData.MaxPlanetRadius, GUILayout.Width(300));
        GUILayout.EndArea();
        PlanetData.PlanetDiameter = Height;
    }
}
