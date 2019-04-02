using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanetGenerator : MonoBehaviour
{

    public Transform viewer;
    public Material instanceMaterial;
    public Camera camera;

    public float maxScale;

    private Chunk chunk;

    public int chunkSize = 50;

    public float maxTerrainHeight;

    private Vector3 planetInfo;

    public Texture2D[] planetTexture;
    public Texture2D[] planetMapTexture;

    public Material atmosphereMaterial;


    [Range(0, 1)]
    public float[] planetTextureRange;
    private float[] planetTextureRangeOld;

    void Start()
    {
        Debug.Log(camera.fieldOfView);
        Debug.Log(camera.nearClipPlane);
        // planetInfo.x = (chunkSize - 1) * maxScale / 2;
        planetInfo.x = maxScale / 2;
        planetInfo.y = maxTerrainHeight;

        instanceMaterial.SetTexture("_Textures", LoadArrayTexture.DoTexture(planetTexture));
        instanceMaterial.SetTexture("_PlanetTextures", LoadArrayTexture.DoTexture(planetMapTexture));

        instanceMaterial.SetInt("_TexturesArrayLength", planetTextureRange.Length);
        instanceMaterial.SetFloatArray("_TexturesArray", planetTextureRange);
        instanceMaterial.SetVector("_PlanetInfo", planetInfo);

      //  createSpehere();
       // Plane[] planes = GeometryUtility.CalculateFrustumPlanes(camera);
    //    Debug.Log(planes[2]);

        chunk = new Chunk(maxScale, chunkSize, instanceMaterial, viewer);
    }

    void createSpehere()
    {
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        sphere.GetComponent<Renderer>().material = atmosphereMaterial;
        sphere.transform.localScale += new Vector3(planetInfo.x * 2 - 5, planetInfo.x * 2 - 5, planetInfo.x * 2 - 5);
    }


    void Update()
    {
   
        instanceMaterial.SetInt("_TexturesArrayLength", planetTextureRange.Length);
        instanceMaterial.SetFloatArray("_TexturesArray", planetTextureRange);

      //  chunk.Update(instanceMaterial);
    }

    void OnDisable()
    {
        chunk.Disable();
    }


}