using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading;
using System.IO;



/******************************
 Modifikovaný Chunked LOD 

    Třída inicializuje jednotlivé stromy algoritmu. Následne je řídí.
 *****************************/
public class ChunksController
{
    private List<Vector4>[] positionsListArray = new List<Vector4>[4];
    private List<Vector4>[] directionListArray = new List<Vector4>[4];


    private Vector4[] directionArray;

    private float scale;

    private float planetRadius;

    private Material material;

    private DrawMeshInstanced[] drawMesh;

    private static Vector3 viewerPosition;
    private static Vector3 viewerPositionOld;
    private static Vector3 viewerRotation;
    private static Vector3 viewerRotationOld;
    private Transform viewer;
    Camera camera;

    private ChunkFace[] chunkFace;

    private Vector4[] directions;
    private Vector3[] directionsY;
    private Vector3[] planetRadiusArray;

    private Mesh mesh;

    int cubeSize = 6;
    int meshTypes = 4;

    Material instanceMaterial;
    Material[] instanceMaterials;

    MaterialPropertyBlock materialBlock;



    public ChunksController(float scale, Material[] instanceMaterials, Camera viewer, MaterialPropertyBlock materialBlock)
    {
        //   planetRadius = (chunkSize - 1) * scale / 2;
        planetRadius = scale / 2;
        /*********
         * Vytvoření pro každou ze šesti stran krychle normálu
         * *********/
        directions = new Vector4[]          { new Vector4(-1, 0, 0, 0),          new Vector4(1, 0, 0, 0),           new Vector4(0, 0, 1, 0),            new Vector4(0, 0, -1, 0),           new Vector4(1, 0, 0, 0),            new Vector4(-1, 0, 0, 0) };
        directionsY = new Vector3[]         { new Vector3(0, 1, 0),             new Vector3(0, 1, 0),               new Vector3(0, 1, 0),               new Vector3(0, 1, 0),               new Vector3(0, 0, 1),               new Vector3(0, 0, 1) };
        SetPlanetRadiusArray(planetRadius);

        this.scale = scale;
        this.viewer = viewer.transform;
        this.camera = viewer;
        this.instanceMaterials = instanceMaterials;
        this.materialBlock = materialBlock;
        InitLists();

        viewerPosition = this.viewer.position;
        chunkFace = new ChunkFace[6];

        createChunkFaces();

        // statická třída, která vytvoří všecchny druhy meshů
        mesh = MeshGenerator.generateTerrainMeshWithSub((int)PlanetData.ChunkSize, (int)scale);

        // následně vytvoří pro každou z nich Instanci která se stará o posílání dat za pomocí instancigu na grafickou kartu.
        drawMesh = new DrawMeshInstanced[4];

        for (int i = 0; i < meshTypes; i++)
        {
            drawMesh[i] = new DrawMeshInstanced(mesh);
        }
  
        UpdateChunkMesh();
    }


    public void Update(Material[] instanceMaterials, MaterialPropertyBlock materialBlock, float newMaxScale)
    {

        viewerPosition = new Vector3(viewer.position.x, viewer.position.y, viewer.position.z);
        viewerRotation = new Vector3(viewer.eulerAngles.x, viewer.eulerAngles.y, viewer.eulerAngles.z);
        this.instanceMaterials = instanceMaterials;
        this.materialBlock = materialBlock;


        // Jestli se zmenili parametry kamery tak proběhne aktualizace
        if (viewerPositionOld != viewerPosition || viewerRotation != viewerRotationOld || newMaxScale != scale)
        {
            if(newMaxScale != scale)
            {
                scale = newMaxScale;
                SetPlanetRadiusArray(newMaxScale / 2);              
            }
            
            viewerPositionOld = viewerPosition;
            viewerRotationOld = viewerRotation;

            UpdateChunkMesh();
        }
        
        UpdateAllMesh();
    }

    /// 
    /// Inicializace vsech sest stromu a predani ukazetelu na sousednistormy
    /// 

    private void createChunkFaces()
    {
        for (int i = 0; i < 6; i++)
        {
            chunkFace[i] = new ChunkFace(null, planetRadiusArray[i], this.scale, camera, directions[i], directionsY[i], true, i);
        }
       

        chunkFace[0].UpdateTopNeighbor(new ChunkFace[] { chunkFace[4], chunkFace[3], chunkFace[5], chunkFace[2] });
        chunkFace[1].UpdateTopNeighbor(new ChunkFace[] { chunkFace[4], chunkFace[2], chunkFace[5], chunkFace[3] });
        chunkFace[2].UpdateTopNeighbor(new ChunkFace[] { chunkFace[4], chunkFace[0], chunkFace[5], chunkFace[1] });
        chunkFace[3].UpdateTopNeighbor(new ChunkFace[] { chunkFace[4], chunkFace[1], chunkFace[5], chunkFace[0] });
        chunkFace[4].UpdateTopNeighbor(new ChunkFace[] { chunkFace[0], chunkFace[2], chunkFace[1], chunkFace[3] });
        chunkFace[5].UpdateTopNeighbor(new ChunkFace[] { chunkFace[0], chunkFace[2], chunkFace[1], chunkFace[3] });
    }

    public void SetPlanetRadiusArray(float newPlanetRadius)
    {
        planetRadiusArray = null;
        planetRadiusArray = new Vector3[] { new Vector3(0, 0, newPlanetRadius), new Vector3(0, 0, -newPlanetRadius), new Vector3(newPlanetRadius, 0, 0), new Vector3(-newPlanetRadius, 0, 0), new Vector3(0, newPlanetRadius, 0), new Vector3(0, -newPlanetRadius, 0) };
    }

    private void InitLists()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i] = new List<Vector4>();
            directionListArray[i] = new List<Vector4>();
        }
    }

    // aktualizace uzlu
    private void UpdateChunkMesh()
    {    

        for (int i =0; i < cubeSize; i++)
        {
            chunkFace[i].Update(viewerPosition, true, planetRadiusArray[i], PlanetData.PlanetDiameter);
        }     

        ClearPositionAndDirection();

        InitLists();
     
        for (int i = 0; i < cubeSize; i++)
        {
            //Po aktualizaci je dulezite načist data pro vykreslení terénu
            List<Vector4>[] pom;
            List<Vector4>[] pomDir;
            pom = chunkFace[i].findAllChunkToDraw();
            pomDir = chunkFace[i].findDirection();

            if (pom == null)
            {
                continue;
            }

            for (int x = 0; x < 4; x++)
            {

                if (pom[x] != null)
                {
                    positionsListArray[x].AddRange(pom[x]);
                }
                if (pomDir[x] != null)
                {
                    directionListArray[x].AddRange(pomDir[x]);
                }
            }

        }

    }

    public void ClearPositionAndDirection()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i].Clear();
            directionListArray[i].Clear();
        }
    }


    // Funkce volá instancing pro vykresleni všech dlazdic
    private void UpdateAllMesh()
    {
        //jsou 4 druhy meshu, ktere mohou byt vykresleny
        for (int i = 0; i < 4; i++)
        {
            Vector4[] viewedChunkCoordd;
            Vector4[] directionArray;

            viewedChunkCoordd = positionsListArray[i].ToArray(); 
            directionArray = directionListArray[i].ToArray();

            if (viewedChunkCoordd.Length > 0)
            {       
                drawMesh[i].UpdateData(viewedChunkCoordd.Length, viewedChunkCoordd, directionArray, i, instanceMaterials[i], materialBlock);
                drawMesh[i].Draw();
            }
        }
    }

    public void Disable()
    {    
        foreach (var item in drawMesh)
        {
            item.Disable();
        }
    }
}