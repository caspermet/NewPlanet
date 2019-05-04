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

    void Start()
    {
        planetInfo.x = maxScale / 2;
        planetInfo.y = maxTerrainHeight;
        PlanetData.PlanetRadius = planetInfo.x;
        PlanetData.MaxPlanetHeight = planetInfo.y;

        cameraController = new CameraController(camera, maxScale / 2);

        SetMaterialProperties();
        chunk = new ChunksController(maxScale, chunkSize, instanceMaterials, camera, materialBlock);
    }

    void SetMaterialProperties()
    {
        materialBlock = new MaterialPropertyBlock();


        materialBlock.SetTexture("_PlanetTextures", planetTexture);
        materialBlock.SetTexture("_PlanetHeightMap", planetHeightMap);
        materialBlock.SetTexture("_PlanetSpecular", planetSpecular);

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
        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetInt("_IsLODActive", (PlanetData.IsLODActive == false ? 0 : 1));
        materialBlock.SetVector("_PlanetInfo", planetInfo);

        cameraController.cameraUpdate();
        chunk.Update(instanceMaterials, materialBlock, maxScale);
    }

    void OnDisable()
    {
        chunk.Disable();
    }


}