using UnityEngine;
using System.Collections;

/****************
 * Stará se o vykreslení uživatelského rozhraní a manipulaci s ním
 * 
 * 
 * 
 * **********************/

public class SceneManager : MonoBehaviour
{
    public Material SkyBox;
    public float Height = 5;
    public float maxHeight = 5;
    public GUIStyle style;
    bool tessellation = false;

    private Vector3 planetInfo;

    private float maxSlider;

    void Start()
    {
        if (PlanetData.IsMenu)
        {
            return;
        }
        
       

        maxSlider = PlanetData.MaxPlanetRadius * 0.01f;
        Height = PlanetData.PlanetDiameter;
        maxHeight = PlanetData.MaxPlanetHeight;
 
        style = new GUIStyle();
        Texture2D texture = new Texture2D(280, 120);
        for (int i = 0; i < 280; i++)
        {
            for (int x = 0; x < 120; x++)
            {
                texture.SetPixel(i, x, new Color(0.4f, 0.4f, 0.4f, 0.6f));
            }
        }
        texture.Apply();
        style.padding.left = 20;
        style.padding.right = 20;
        style.padding.top = 18;

        style.normal.background = texture;

        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = PlanetData.MaxPlanetHeight;
        tessellation = PlanetData.IsTessellation;
        SkyBox.SetVector("_PlanetInfo", planetInfo);
    }

    void Update()
    {
        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = PlanetData.MaxPlanetHeight;

        //shader který má na startost skybox
        SkyBox.SetVector("_PlanetInfo", planetInfo);
        
    }

    void OnGUI()
    {
        //Samotny layout
        GUILayout.BeginArea(new Rect(0, 0, 280, 180), style);
        maxSlider = Height * 0.01f;
        if(maxHeight > maxSlider)
        {
            maxHeight = maxSlider;
        }
        if (GUILayout.Button("Ukončit aplikaci"))
        {
            Application.Quit();
        }

        GUILayout.Label("Průměr planety = " + Height + " m", GUILayout.ExpandWidth(false));
        Height = GUILayout.HorizontalSlider(Height, PlanetData.MinPlanetRadius, PlanetData.MaxPlanetRadius, GUILayout.Width(200));
        GUILayout.Label("Maximální výška hor = " + maxHeight + " m", GUILayout.ExpandWidth(false));
        maxHeight = GUILayout.HorizontalSlider(maxHeight, 0, maxSlider, GUILayout.Width(200));

        tessellation = GUILayout.Toggle(tessellation, "Teselace na odstranění popping efektu");

        GUILayout.EndArea();
       

        // získaná se aktualizují
        PlanetData.PlanetDiameter = Height;
        PlanetData.MaxPlanetHeight = maxHeight;
        PlanetData.IsTessellation = tessellation;
    }

}
