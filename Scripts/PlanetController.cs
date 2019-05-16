using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;


public class PlanetController : MonoBehaviour
{
    public Camera camera;

    private Vector3 planetInfo;


    /// Vyskova mapa planety, textura planety a specularni slozka
    public Texture2D planetTexture;
    public Texture2D planetHeightMap;
    public Texture2D planetSpecular;

    public Material subPlanetMaterial;

    public Texture2D[]texture;

    // instance materialu pro meshe
    public Material[] instanceMaterials;

    private float gamma = 1.0f;
    private float hdrExposure = 1.0f;

    private GameObject sphere;

    // Instance Chunk controleru
    private ChunksController chunk;

    // Instace Controlleru camery
    private CameraController cameraController;

    // Material block, který je přidán do isntace
    private MaterialPropertyBlock materialBlock;


    void Start()
    {
        // predaní zakladnich parametru na grafickou kartu

        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = PlanetData.MaxPlanetHeight;
        planetInfo.z = PlanetData.ChunkSize;

        PlanetData.CameraPosition = camera.transform.position;
        CreateSpehere();


        cameraController = new CameraController(camera, PlanetData.PlanetRadius);

        SetMaterialProperties();
        chunk = new ChunksController(PlanetData.PlanetDiameter, instanceMaterials, camera, materialBlock);
      
    }

    // nastaví přoměné které se pošlou na grafickou kartu
    void SetMaterialProperties()
    {
        materialBlock = new MaterialPropertyBlock();

        materialBlock.SetTexture("_SurfaceTexture", LoadArrayTexture.DoTexture(texture));
        materialBlock.SetTexture("_PlanetTextures", planetTexture);
        materialBlock.SetTexture("_PlanetHeightMap", planetHeightMap);
        materialBlock.SetTexture("_PlanetSpecular", planetSpecular);

       // materialBlock.SetTexture("_noiseTexture", PerlingNoise.CreateNoise((int)width, noise));

        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetVector("_PlanetInfo", planetInfo);
        materialBlock.SetFloat("_Gamma", gamma);
        materialBlock.SetFloat("fHdrExposure", hdrExposure);
        materialBlock.SetInt("_IsLODActive", 0);     
    }

    // Aktualizuje data 
    void UpdateData()
    {
        PlanetData.CameraPosition = camera.transform.position;
        cameraController.setDistance(PlanetData.PlanetRadius);

        PlanetData.ViewDistanceFromeEarth = Vector3.Distance(new Vector3(0, 0, 0), PlanetData.CameraPosition) - PlanetData.PlanetRadius;
       
        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = PlanetData.MaxPlanetHeight;

        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetInt("_IsLODActive", (PlanetData.IsLODActive == false ? 0 : 1));
        materialBlock.SetVector("_PlanetInfo", planetInfo);
        materialBlock.SetInt("_IsTessellation", PlanetData.IsTessellation == true ? 1 : 0 );

        sphere.transform.localScale = new Vector3(planetInfo.x * 1.98f, planetInfo.x * 1.98f, planetInfo.x * 1.98f);
    }

    void CreateSpehere()
    {
        sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.AddComponent<BoxCollider>();
        sphere.GetComponent<MeshRenderer>().material = subPlanetMaterial;
        sphere.transform.localScale = new Vector3(planetInfo.x * 1.98f, planetInfo.x * 1.98f, planetInfo.x * 1.98f);
    }

    void Update()
    {
        UpdateData();

        cameraController.cameraUpdate();
        chunk.Update(instanceMaterials, materialBlock, PlanetData.PlanetDiameter);
     
    }

    void OnDisable()
    {
        chunk.Disable();
    }

}