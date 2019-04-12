using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Threading;

public class Chunk
{
    const float viewerMoveThresholdForChunkUpdate = 50f;
    const float sqrViewerMoveThresholdForChunkUpdate = viewerMoveThresholdForChunkUpdate * viewerMoveThresholdForChunkUpdate;

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
    private int chunkSize;

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

    private Vector3[] directions;
    private Vector3[] directionsY;
    private Vector3[] planetRadiusArray;

    static object chunkFaceLock = new object();
    static object chunkUpdateLock = new object();

    private Mesh mesh;

    int cubeSize = 1;

    Material instanceMaterial;
    Material[] instanceMaterials;

    MaterialPropertyBlock materialBlock;

    public Chunk(float scale, int chunkSize, Material[] instanceMaterials, Camera viewer, MaterialPropertyBlock materialBlock)
    {
        //   planetRadius = (chunkSize - 1) * scale / 2;
        planetRadius = scale / 2;

        //  directions = new Vector3[] { new Vector3(0, 0, -90), new Vector3(0, 180, 90), new Vector3(90, 270, 0), new Vector3(-90, 1, 0), new Vector3(0, 0, 0), new Vector3(0, 0, 180) };
        //  directions = new Vector4[] { new Vector4(1, 0, 0, 0), new Vector4(-1, 0, 0, 0), new Vector4(0, 1, 0, 0), new Vector4(0, -1, 0, 0), new Vector4(0, 0, 1, 0), new Vector4(0, 0, -1, 0) };
        directions = new Vector3[] { new Vector3(1, 0, 0), new Vector3(-1, 0, 0), new Vector3(0, -1, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(0, 0, -1) };
        directionsY = new Vector3[] { new Vector3(0, 1, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 1), new Vector3(1, 0, 0), new Vector3(1, 0, 0) };
        planetRadiusArray = new Vector3[] { new Vector3(0, 0, -planetRadius), new Vector3(0, 0, planetRadius), new Vector3(planetRadius, 0, 0), new Vector3(-planetRadius, 0, 0), new Vector3(0, planetRadius, 0), new Vector3(0, -planetRadius, 0) };

        this.scale = scale;
        this.viewer = viewer.transform;
        this.chunkSize = chunkSize;
        this.camera = viewer;
        this.instanceMaterials = instanceMaterials;
        this.materialBlock = materialBlock;
        InitLists();

        viewerPosition = this.viewer.position;
        chunkFace = new ChunkFace[6];

        chunkCoordArray = new Vector4[numberOfEdge][];
        chunkDirection = new Vector4[numberOfEdge][];

        for (int index = 0; index < 6; index++)
        {
            chunkFace[index] = new ChunkFace(null, planetRadiusArray[index], this.scale, camera, directions[index], directionsY[index], planetRadius, true, 0, null);
        }

        mesh = MeshGenerator.generateTerrainMeshWithSub(chunkSize, (int)scale);

        drawMesh = new DrawMeshInstanced[4];
        drawMesh[0] = new DrawMeshInstanced(mesh);
        drawMesh[1] = new DrawMeshInstanced(mesh);
        drawMesh[2] = new DrawMeshInstanced(mesh);
        drawMesh[3] = new DrawMeshInstanced(mesh);
        UpdateChunkMesh();
    }


    public void Update(Material[] instanceMaterials, MaterialPropertyBlock materialBlock)
    {
        viewerPosition = new Vector3(viewer.position.x, viewer.position.y, viewer.position.z);
        viewerRotation = new Vector3(viewer.eulerAngles.x, viewer.eulerAngles.y, viewer.eulerAngles.z);
        this.instanceMaterials = instanceMaterials;
        this.materialBlock = materialBlock;

        if (viewerPositionOld != viewerPosition || viewerRotation != viewerRotationOld)
        {

            viewerPositionOld = viewerPosition;
            viewerRotationOld = viewerRotation;

            UpdateChunkMesh();
            viewedChunkCoord = positionsList.ToArray();

        }

        UpdateAllMesh();
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

        for (int i = 0; i < cubeSize; i++)
        {

            chunkFace[i].Update(viewerPosition, true);
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
}