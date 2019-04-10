using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanetGenerator : MonoBehaviour
{
    public float noise = 20;
    public float width = 20;

    public Transform viewer;
    public Material instanceMaterial;
    public Camera camera;
    CameraEdit cameraEditor;

    public float maxScale;

    private Chunk chunk;

    public int chunkSize = 50;

    public float maxTerrainHeight;

    private Vector3 planetInfo;

    public Texture2D[] planetTexture;

    public Texture2D[] planetMapTextureTop;
    public Texture2D[] planetMapTextureBottom;

    public Texture2D[] planetHeightMapTop;
    public Texture2D[] planetHeightMapBottom;

    public Material atmosphereMaterial;

    private float gamma = 1.0f;
    public float hdrExposure = 1.0f;

    [Range(0, 1)]
    public float[] planetTextureRange;
    private float[] planetTextureRangeOld;

    MaterialPropertyBlock materialBlock;


    GameObject sphere;

    void Start()
    {
      
        planetInfo.x = maxScale / 2;
        planetInfo.y = maxTerrainHeight;

        cameraEditor = new CameraEdit(camera, maxScale / 2);
        CreateSpehere();
        SetMaterialProperties();
        chunk = new Chunk(maxScale, chunkSize, instanceMaterial, camera);
    }

    public Texture2D perlinNoise;
    void SetMaterialProperties()
    {
        instanceMaterial.SetTexture("_SurfaceTexture", LoadArrayTexture.DoTexture(planetTexture));

        instanceMaterial.SetTexture("_PlanetTexturesTop", LoadArrayTexture.DoTexture(planetMapTextureTop));
        instanceMaterial.SetTexture("_PlanetTexturesBottom", LoadArrayTexture.DoTexture(planetMapTextureBottom));
        instanceMaterial.SetTexture("_PlanetHeightMapTop", LoadArrayTexture.DoTexture(planetHeightMapTop));
        instanceMaterial.SetTexture("_PlanetHeightMapBottom", LoadArrayTexture.DoTexture(planetHeightMapBottom));
        instanceMaterial.SetTexture("_noiseTexture", perlinNoise = PerlingNoise.CreateNoise((int)width, noise));

        instanceMaterial.SetInt("_TexturesArrayLength", planetTextureRange.Length);
        instanceMaterial.SetFloatArray("_TexturesArray", planetTextureRange);
        instanceMaterial.SetVector("_CameraPosition", camera.transform.position);
        instanceMaterial.SetVector("_PlanetInfo", planetInfo);
        instanceMaterial.SetFloat("_Gamma", gamma);
        instanceMaterial.SetFloat("fHdrExposure", hdrExposure);


        materialBlock.SetTexture("_SurfaceTexture", LoadArrayTexture.DoTexture(planetTexture));

        materialBlock.SetTexture("_PlanetTexturesTop", LoadArrayTexture.DoTexture(planetMapTextureTop));
        materialBlock.SetTexture("_PlanetTexturesBottom", LoadArrayTexture.DoTexture(planetMapTextureBottom));
        materialBlock.SetTexture("_PlanetHeightMapTop", LoadArrayTexture.DoTexture(planetHeightMapTop));
        materialBlock.SetTexture("_PlanetHeightMapBottom", LoadArrayTexture.DoTexture(planetHeightMapBottom));
        materialBlock.SetTexture("_noiseTexture", perlinNoise = PerlingNoise.CreateNoise((int)width, noise));

        materialBlock.SetInt("_TexturesArrayLength", planetTextureRange.Length);
        materialBlock.SetFloatArray("_TexturesArray", planetTextureRange);
        materialBlock.SetVector("_CameraPosition", camera.transform.position);
        materialBlock.SetVector("_PlanetInfo", planetInfo);
        materialBlock.SetFloat("_Gamma", gamma);
        materialBlock.SetFloat("fHdrExposure", hdrExposure);
    }

    void CreateSpehere()
    {
       // atmosphereMaterial.SetTexture("_noise", PerlingNoise.CreateNoise((int)width, noise));
        sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.GetComponent<Renderer>().material = atmosphereMaterial;
        sphere.transform.localScale += new Vector3(planetInfo.x * 2 - 5, planetInfo.x * 2 - 5, planetInfo.x * 2 - 5);
    }


    void Update()
    {
        instanceMaterial.SetInt("_TexturesArrayLength", planetTextureRange.Length);
        instanceMaterial.SetFloatArray("_TexturesArray", planetTextureRange);
        instanceMaterial.SetVector("_CameraPosition", camera.transform.position);

       // atmosphereMaterial.SetTexture("_noise", PerlingNoise.CreateNoise((int)width, noise));

        cameraEditor.cameraUpdate();
        chunk.Update(instanceMaterial);
    }

    void OnDisable()
    {
        chunk.Disable();
    }


}