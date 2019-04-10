using UnityEngine;
using System.Collections;

public static class MeshGenerator
{

    public static Mesh GenerateTerrainMesh(int chunkSize, int scale, Mesh mesh)
    {
        float topLeftX = (chunkSize - 1) / -2f;
        float topLeftZ = (chunkSize - 1) / 2f;

        MeshData meshData = new MeshData(chunkSize, chunkSize, 0, mesh);
        int vertexIndex = 0;

        for (int y = 0; y < chunkSize; y++)
        {
            for (int x = 0; x < chunkSize; x++)
            {

                meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y) / (chunkSize - 1));
                meshData.uvs[vertexIndex] = new Vector2(x / (float)chunkSize, y /(float)chunkSize);

                if (x < chunkSize - 1 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1, vertexIndex + chunkSize);
                    meshData.AddTriangle(vertexIndex + chunkSize + 1, vertexIndex, vertexIndex + 1);
                }

                vertexIndex++;
            }
        }
        meshData.CreateMesh();

        return meshData;
    }

    public static Mesh GenerateTerrainMeshRight(int chunkSize, int scale, Mesh mesh)
    {
        float topLeftX = (chunkSize - 1) / -2f;
        float topLeftZ = (chunkSize - 1) / 2f;

        MeshData meshData = new MeshData(chunkSize, chunkSize, chunkSize);
        int vertexIndex = 0;

        for (int y = 0; y < chunkSize; y++)
        {
            for (int x = 0; x < chunkSize; x++)
            {
                meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y) / (chunkSize - 1));

                if (x == chunkSize - 1 && y < chunkSize - 1)
                {
                    vertexIndex++;
                    meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y - 0.5f) / (chunkSize - 1));
                }

                if (x == chunkSize - 2 && y < chunkSize - 1)
                {
                      meshData.AddTriangle(vertexIndex, vertexIndex + 1 + 1, vertexIndex + chunkSize + 1 + 1);
                      meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 1, vertexIndex + chunkSize + 1);
                      meshData.AddTriangle(vertexIndex + 1 + 1, vertexIndex, vertexIndex + 1);               
                }
                else if (x < chunkSize - 1 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 1, vertexIndex + chunkSize + 1);
                    meshData.AddTriangle(vertexIndex + chunkSize + 1 + 1, vertexIndex, vertexIndex + 1);
                }

                vertexIndex++;              
            }
        }
        meshData.CreateMesh();

        return meshData;
    }

    public static Mesh GenerateTerrainMeshTwoEdge(int chunkSize, int scale, Mesh mesh)
    {
        float topLeftX = (chunkSize - 1) / -2f;
        float topLeftZ = (chunkSize - 1) / 2f;

        int edge = 2;

        MeshData meshData = new MeshData(chunkSize, chunkSize, chunkSize * 2);
        int vertexIndex = 0;

        for (int y = 0; y < chunkSize; y++)
        {
            for (int x = 0; x < chunkSize; x++)
            {
                meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y) / (chunkSize - 1));

                if (x == chunkSize - 1 && y < chunkSize - 1)
                {
                    vertexIndex++;
                    meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y - 0.5f) / (chunkSize - 1));
                }

                if (y == chunkSize - 1 && x < chunkSize - 1)
                {
                    vertexIndex++;
                    meshData.vertices[vertexIndex] = new Vector3((topLeftX + x + 0.5f) / (chunkSize - 1), 0, (topLeftZ - y) / (chunkSize - 1));
                }

                if (y == chunkSize - 2 && x == chunkSize - 2)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + 2);
                    meshData.AddTriangle(vertexIndex, vertexIndex +  2, vertexIndex + chunkSize + 3 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3 + x, vertexIndex + chunkSize + 2 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 2 + x, vertexIndex + chunkSize + 1 + x);
                }
                else if (x == chunkSize - 2 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1 + 1, vertexIndex + chunkSize + 1 + 1);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 1, vertexIndex + chunkSize + 1);
                    meshData.AddTriangle(vertexIndex + 1 + 1, vertexIndex, vertexIndex + 1);
                }            
                else if (y == chunkSize - 2 && x < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 3 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3 + x, vertexIndex + chunkSize + 2 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 2 + x, vertexIndex + chunkSize  + 1 + x);
                }
                else if (x < chunkSize - 1 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 1, vertexIndex + chunkSize + 1);
                    meshData.AddTriangle(vertexIndex + chunkSize + 1 + 1, vertexIndex, vertexIndex + 1);
                }

                vertexIndex++;
            }
        }
        meshData.CreateMesh();

        return meshData;
    }

    public static Mesh GenerateTerrainMeshThreeEdge(int chunkSize, int scale, Mesh mesh)
    {
        float topLeftX = (chunkSize - 1) / -2f;
        float topLeftZ = (chunkSize - 1) / 2f;

        int edge = 2;

        MeshData meshData = new MeshData(chunkSize, chunkSize, chunkSize * 3);
        int vertexIndex = 0;

        for (int y = 0; y < chunkSize; y++)
        {
            for (int x = 0; x < chunkSize; x++)
            {

                if (x == 0 && y > 0)
                {                 
                    meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y + 0.5f) / (chunkSize - 1));
                    vertexIndex++;
                }

                meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y) / (chunkSize - 1));

                if (x == chunkSize - 1 && y < chunkSize - 1)
                {
                    vertexIndex++;
                    meshData.vertices[vertexIndex] = new Vector3((topLeftX + x) / (chunkSize - 1), 0, (topLeftZ - y - 0.5f) / (chunkSize - 1));
                }            

                if (y == chunkSize - 1 && x < chunkSize - 1)
                {
                    vertexIndex++;
                    meshData.vertices[vertexIndex] = new Vector3((topLeftX + x + 0.5f) / (chunkSize - 1), 0, (topLeftZ - y) / (chunkSize - 1));
                }

                if (y == chunkSize - 2 && x == chunkSize - 2)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + 2);
                    meshData.AddTriangle(vertexIndex, vertexIndex + 2, vertexIndex + chunkSize + 4 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 4 + x, vertexIndex + chunkSize + 3 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3 + x, vertexIndex + chunkSize + 2 + x);
                }
                else if (y == chunkSize - 2 && x == 0)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 4);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 4, vertexIndex + chunkSize + 1);
                    meshData.AddTriangle(vertexIndex + chunkSize + 1, vertexIndex + chunkSize + 4, vertexIndex + chunkSize + 3);
                    meshData.AddTriangle(vertexIndex + chunkSize + 1, vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 2);
                }
                else if (x == chunkSize - 2 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1 + 1, vertexIndex + chunkSize + 3);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 2);
                    meshData.AddTriangle(vertexIndex + 1 + 1, vertexIndex, vertexIndex + 1);
                }
                else if (x == 0 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 3);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 1);
                    meshData.AddTriangle(vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 2, vertexIndex + chunkSize + 1);
                }
                else if (y == chunkSize - 2 && x < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 4 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 4 + x, vertexIndex + chunkSize + 3 + x);
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3 + x, vertexIndex + chunkSize + 2 + x);
                }
                else if (x < chunkSize - 1 && y < chunkSize - 1)
                {
                    meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 2, vertexIndex + chunkSize + 2);
                    meshData.AddTriangle(vertexIndex + chunkSize + 1 + 2, vertexIndex, vertexIndex + 1);
                }

                vertexIndex++;
            }
        }
        meshData.CreateMesh();

        return meshData;
    }
}

public class MeshData
{
    public Vector3[] vertices;
    public int[] triangles;
    public Vector2[] uvs;
    private Mesh mesh;
    private int meshIndex;

    int triangleIndex;

    public MeshData(int meshWidth, int meshHeight, int meshEdge, Mesh mesh)
    {
        vertices = new Vector3[meshWidth * meshHeight + meshEdge - 1];
        triangles = new int[(meshWidth - 1) * (meshHeight - 1) * 6 + (meshEdge - 1) * 3];
        this.mesh = mesh;
        meshIndex = mesh.subMeshCount;
    }

    public void AddTriangle(int a, int b, int c)
    {
        triangles[triangleIndex] = a;
        triangles[triangleIndex + 1] = b;
        triangles[triangleIndex + 2] = c;
        triangleIndex += 3;
    }

    public void CreateMesh()
    {
        mesh.vertices = vertices;

        mesh.SetTriangles(triangles, meshIndex);
        mesh.SetVertices(vertices, meshIndex);
        mesh.RecalculateNormals();

    }

    public Mesh GetMesh()
    {
        return mesh;
    }
}