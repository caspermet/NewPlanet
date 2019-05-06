using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanetController : MonoBehaviour
{ 
    public float noise = 20;
    public float width = 20;  

    public Material instanceMaterial;
    public Camera camera;

    public float maxScale;

    public int chunkSize = 50;
    public float maxTerrainHeight;

    private Vector3 planetInfo;

    public Texture2D planetTexture;
    public Texture2D planetHeightMap;
    public Texture2D planetSpecular;

    public Material[] instanceMaterials;

    private float gamma = 1.0f;
    private float hdrExposure = 1.0f;

    private GameObject sphere;
    private ChunksController chunk;
    private CameraController cameraController;
    private MaterialPropertyBlock materialBlock;

    public Texture2D normalMaps;

    void Start()
    {
        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = maxTerrainHeight;
        // PlanetData.PlanetRadius = planetInfo.x;
        //PlanetData.MaxPlanetHeight = planetInfo.y;
       // normalMaps = CreateNormalMap.NormalMap(planetHeightMap, 1);

        cameraController = new CameraController(camera, PlanetData.PlanetRadius);

        SetMaterialProperties();
        chunk = new ChunksController(PlanetData.PlanetDiameter, chunkSize, instanceMaterials, camera, materialBlock);
    }

    void SetMaterialProperties()
    {
        materialBlock = new MaterialPropertyBlock();


        materialBlock.SetTexture("_PlanetTextures", planetTexture);
        materialBlock.SetTexture("_PlanetHeightMap", planetHeightMap);
        materialBlock.SetTexture("_PlanetSpecular", planetSpecular);
       // materialBlock.SetTexture("_PlanetNormalMap", normalMaps);

        materialBlock.SetTexture("_noiseTexture", PerlingNoise.CreateNoise((int)width, noise));

        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetVector("_PlanetInfo", planetInfo);
        materialBlock.SetFloat("_Gamma", gamma);
        materialBlock.SetFloat("fHdrExposure", hdrExposure);
        materialBlock.SetInt("_IsLODActive", 0);
    }

    void CreateSpehere()
    {
        sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.transform.localScale += new Vector3(planetInfo.x * 2 - 5, planetInfo.x * 2 - 5, planetInfo.x * 2 - 5);
    }


    void Update()
    {
        planetInfo.x = PlanetData.PlanetRadius;
        cameraController.setDistance(PlanetData.PlanetRadius);
        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetInt("_IsLODActive", (PlanetData.IsLODActive == false ? 0 : 1));
        materialBlock.SetVector("_PlanetInfo", planetInfo);

        cameraController.cameraUpdate();
        chunk.Update(instanceMaterials, materialBlock, PlanetData.PlanetDiameter); 
    }

    void OnDisable()
    {
        chunk.Disable();
    }


}