using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;

public class PlanetController : MonoBehaviour
{
    public float noise = 20;
    public float width = 20;

    public Material clouds;
    public Camera camera;

    public float maxScale;

    public int chunkSize = 50;
    public float maxTerrainHeight;

    private Vector3 planetInfo;

    public Texture2D planetTexture;
    public Texture2D planetHeightMap;
    public Texture2D planetSpecular;


    public Texture2D[]texture;

    public Material[] instanceMaterials;

    private float gamma = 1.0f;
    private float hdrExposure = 1.0f;

    private GameObject sphere;
    private ChunksController chunk;
    private CameraController cameraController;
    private MaterialPropertyBlock materialBlock;

    public Texture2D normalMapss;
    public int angle;

    public Layer[] layers;

    void Start()
    {
        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = PlanetData.MaxPlanetHeight;
        PlanetData.CameraPosition = camera.transform.position;
        // PlanetData.PlanetRadius = planetInfo.x;
        //PlanetData.MaxPlanetHeight = planetInfo.y;
        // normalMapss = CreateNormalMap.NormalMap(planetHeightMap, 1);
        // normalMapss = LoadPNG("Assets/Map/gebco_08_rev_elev_21600x10800.png");
       // CreateSpehere();
  
        cameraController = new CameraController(camera, PlanetData.PlanetRadius);

        SetMaterialProperties();
        chunk = new ChunksController(PlanetData.PlanetDiameter, chunkSize, instanceMaterials, camera, materialBlock);
    }

    void SetMaterialProperties()
    {
        materialBlock = new MaterialPropertyBlock();

        materialBlock.SetTexture("_SurfaceTexture", LoadArrayTexture.DoTexture(texture));
        materialBlock.SetTexture("_PlanetTextures", planetTexture);
        materialBlock.SetTexture("_PlanetHeightMap", planetHeightMap);
        materialBlock.SetTexture("_PlanetSpecular", planetSpecular);
        // materialBlock.SetTexture("_PlanetNormalMap", normalMapss);

        materialBlock.SetTexture("_noiseTexture", PerlingNoise.CreateNoise((int)width, noise));

        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetVector("_PlanetInfo", planetInfo);
        materialBlock.SetFloat("_Gamma", gamma);
        materialBlock.SetFloat("fHdrExposure", hdrExposure);
        materialBlock.SetInt("_IsLODActive", 0);

        materialBlock.SetInt("layerCount", layers.Length);
        materialBlock.SetFloatArray("baseStartHeights", layers.Select(x => x.startAngle).ToArray());
        materialBlock.SetFloatArray("baseBlends", layers.Select(x => x.blendStrength).ToArray());
        materialBlock.SetFloatArray("baseColourStrength", layers.Select(x => x.tintStrength).ToArray());

        Texture2DArray texturesArray = LoadArrayTexture.DoTexture(layers.Select(x => x.texture).ToArray());
        materialBlock.SetTexture("baseTextures", texturesArray);
    }

    void CreateSpehere()
    {
        sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        //   sphere.GetComponent<MeshRenderer>().material = clouds;
        sphere.transform.localScale = new Vector3(planetInfo.x * 2.3f, planetInfo.x * 2.3f, planetInfo.x * 2.3f);
    }




    void Update()
    {
        planetInfo.x = PlanetData.PlanetRadius;
        planetInfo.y = PlanetData.MaxPlanetHeight;
        PlanetData.CameraPosition = camera.transform.position;
        PlanetData.Angle = angle;
      
        cameraController.setDistance(PlanetData.PlanetRadius);
        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetInt("_IsLODActive", (PlanetData.IsLODActive == false ? 0 : 1));
        materialBlock.SetVector("_PlanetInfo", planetInfo);

        materialBlock.SetInt("layerCount", layers.Length);
        materialBlock.SetFloatArray("baseStartHeights", layers.Select(x => x.startAngle).ToArray());
        materialBlock.SetFloatArray("baseBlends", layers.Select(x => x.blendStrength).ToArray());
        materialBlock.SetFloatArray("baseColourStrength", layers.Select(x => x.tintStrength).ToArray());

      /*  Texture2DArray texturesArray = LoadArrayTexture.DoTexture(layers.Select(x => x.texture).ToArray());
        materialBlock.SetTexture("baseTextures", texturesArray);*/



        cameraController.cameraUpdate();
        chunk.Update(instanceMaterials, materialBlock, PlanetData.PlanetDiameter); 
    }

    void OnDisable()
    {
        chunk.Disable();
    }

    [System.Serializable]
    public class Layer
    {
        public Texture2D texture;
        [Range(0, 1)]
        public float tintStrength;
        [Range(0, 1)]
        public float startAngle;
        [Range(0, 1)]
        public float blendStrength;
    }
}