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

    private List<Vector4> positionsList = new List<Vector4>();
    private List<Vector4> directionList = new List<Vector4>();

    private List<Vector4>[] positionsListArray = new List<Vector4>[4];
    private List<Vector4>[] directionListArray = new List<Vector4>[4];


    private Vector4[] viewedChunkCoord;
    private Vector4[] directionArray;

    private int numberOfEdge = 2;
    private Vector4[][] chunkCoordArray;
    private Vector4[][] chunkDirection;

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

    static object chunkFaceLock = new object();
    static object chunkUpdateLock = new object();

    private Mesh mesh;

    int cubeSize = 6;

    Material instanceMaterial;
    Material[] instanceMaterials;

    MaterialPropertyBlock materialBlock;

    public int avgFrameRate;



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

        chunkCoordArray = new Vector4[numberOfEdge][];
        chunkDirection = new Vector4[numberOfEdge][];

        createChunkFaces();

        // statická třída, která vytvoří všecchny druhy meshů
        mesh = MeshGenerator.generateTerrainMeshWithSub((int)PlanetData.ChunkSize, (int)scale);

        // následně vytvoří pro každou z nich Instanci která se stará o posílání dat za pomocí instancigu na grafickou kartu.
        drawMesh = new DrawMeshInstanced[4];
        drawMesh[0] = new DrawMeshInstanced(mesh);
        drawMesh[1] = new DrawMeshInstanced(mesh);
        drawMesh[2] = new DrawMeshInstanced(mesh);
        drawMesh[3] = new DrawMeshInstanced(mesh);

       

        UpdateChunkMesh();
    }


    public void Update(Material[] instanceMaterials, MaterialPropertyBlock materialBlock, float newMaxScale)
    {

        viewerPosition = new Vector3(viewer.position.x, viewer.position.y, viewer.position.z);
        viewerRotation = new Vector3(viewer.eulerAngles.x, viewer.eulerAngles.y, viewer.eulerAngles.z);
        this.instanceMaterials = instanceMaterials;
        this.materialBlock = materialBlock;

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
            viewedChunkCoord = positionsList.ToArray();
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
            chunkFace[i] = new ChunkFace(null, planetRadiusArray[i], this.scale, camera, directions[i], directionsY[i], true, i, null);
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

    private void UpdateAllMesh()
    {
        int lenght = 0;
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
                lenght += viewedChunkCoordd.Length;
            }
        }
        Frame(15 * 15 * 2 * lenght);
    }

    private void GetActiveChunksFromChunkTree(ref List<ChunkFace> chunkFaceList, ChunkFace chunkTree)
    {
        if (chunkTree.getChunkTree() != null)
        {
            for (int i = 0; i < chunkTree.getChunkTree().Length; i++)
            {
                GetActiveChunksFromChunkTree(ref chunkFaceList, chunkTree.getChunkTree()[i]);
            }
        }
        else
        {
            chunkFaceList.Add(chunkTree);
        }
    }

    public void Disable()
    {
       
        foreach (var item in drawMesh)
        {
            item.Disable();
        }
  
    }


    void Frame(int lenght)
    {
        float current = 0;
        current = Time.frameCount / Time.time;
        avgFrameRate = (int)current;
       // WriteString(avgFrameRate);

    }

    public void WriteString(int fps)
    {
        string path;
        StreamWriter writer;

        
        float vzdalenost = Vector3.Distance(new Vector3(0,0,0) ,PlanetData.CameraPosition) - PlanetData.PlanetRadius; 

        path = "Assets/test-fps.txt";
        writer = new StreamWriter(path, true);
        writer.WriteLine(fps);
        writer.Close();

        string path2;
        StreamWriter writer2;

        path2 = "Assets/test-vzdalenost.txt";
        writer2 = new StreamWriter(path2, true);
        writer2.WriteLine((int)vzdalenost);
        writer2.Close();


    }
}