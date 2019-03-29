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

    private Vector4[] viewedChunkCoord;
    private Vector4[] directionArray;

    private float scale;
    private int chunkSize;

    private float planetRadius;

    private Material material;

    private DrawMeshInstanced drawMesh;

    private static Vector3 viewerPosition;
    private static Vector3 viewerPositionOld;
    private Transform viewer;

    private ChunkFace[] chunkFace;

    private MeshData meshData;

    private Vector3[] directions;
    private Vector3[] directionsY;
    private Vector3[] planetRadiusArray;

    static object chunkFaceLock = new object();
    static object chunkUpdateLock = new object();


    int cubeSize = 6;

    public Chunk(float scale, int chunkSize, Material instanceMaterial, Transform viewer)
    {
     //   planetRadius = (chunkSize - 1) * scale / 2;
        planetRadius = scale / 2;

        directions = new Vector3[] { new Vector3(-1, 0, 0), new Vector3(1, 0, 0), new Vector3(0, -1, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(0, 0, -1) };
        directionsY = new Vector3[] { new Vector3(0, 1, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 1), new Vector3(1, 0, 0), new Vector3(1, 0, 0) };
        planetRadiusArray = new Vector3[] { new Vector3(0, 0, planetRadius), new Vector3(0, 0, -planetRadius), new Vector3(planetRadius, 0, 0), new Vector3(-planetRadius, 0, 0), new Vector3(0, planetRadius, 0), new Vector3(0, -planetRadius, 0) };
       
        this.scale = scale;
        this.viewer = viewer;
        this.chunkSize = chunkSize;

        viewerPosition = viewer.position;
        chunkFace = new ChunkFace[6];
        Thread[] objThread = new Thread[cubeSize];

        //Vytvoreni vlaken pro vytvoreni cube
        for (int index = 0; index < 6; index++)
        {
            chunkThreade(index);
        }

        meshData = MeshGenerator.GenerateTerrainMesh(chunkSize, (int)scale);
        meshData.CreateMesh();

        drawMesh = new DrawMeshInstanced(meshData.GetMesh(), instanceMaterial);

        for (int i = 0; i < cubeSize; i++)
        {
            positionsList.AddRange(chunkFace[i].GetPositionList());
            directionList.AddRange(chunkFace[i].GetDirectionList());
        }

        viewedChunkCoord = positionsList.ToArray();
        directionArray = directionList.ToArray();

        drawMesh.UpdateData(positionsList.Count, viewedChunkCoord, directionArray) ;
        

    }

    private void chunkThreade(int index)
    {

        new Thread(() =>
        {
            Thread.CurrentThread.IsBackground = true;
            ChunkFace chunkFaceInThreade;
            chunkFaceInThreade = new ChunkFace(null, planetRadiusArray[index], this.scale, (chunkSize - 1), viewerPosition, directions[index], directionsY[index], planetRadius);

            lock (chunkFaceLock)
            {
                chunkFace[index] = chunkFaceInThreade;
            }
        }).Start();

       
    }

    public void Update(Material instanceMaterial)
    {
        viewerPosition = new Vector3(viewer.position.x, viewer.position.y, viewer.position.z);

        if (viewerPositionOld != viewerPosition)
        {
            viewerPositionOld = viewerPosition;

            UpdateChunkMesh();
            viewedChunkCoord = positionsList.ToArray();

        }

        if (positionsList.Count > 0)
        {
           // drawMesh.UpdateData(positionsList.Count, viewedChunkCoord, directionArray);
            drawMesh.Draw();
        }
    }

    private void UpdateChunkMesh()
    {
       
        positionsList.Clear();
        directionList.Clear();

        for (int i = 0; i < cubeSize; i++)
        {
            positionsList.AddRange(chunkFace[i].Update(viewerPosition));
            directionList.AddRange(chunkFace[i].GetDirectionList());          
        }

        viewedChunkCoord = positionsList.ToArray();
        directionArray = directionList.ToArray();

        if (viewedChunkCoord.Length > 0)
        {

            drawMesh.UpdateData(positionsList.Count, viewedChunkCoord, directionArray);
        }
    }

    private void UpdateChunkByThreade(int index)
    {
        new Thread(() =>
        {
            List<Vector4> listOfPosition;
            List<Vector4> listOfDirection;
            listOfPosition = chunkFace[index].Update(viewerPosition);
            listOfDirection = chunkFace[index].GetDirectionList();

            lock (chunkUpdateLock)
            {
                positionsList.AddRange(listOfPosition);
                directionList.AddRange(listOfDirection);
            }
        }).Start();
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
        drawMesh.Disable();
    }
}