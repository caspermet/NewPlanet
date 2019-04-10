using UnityEngine;
using System.Collections;

public static class MeshGenerator
{

    public static Mesh generateTerrainMeshWithSub(int chunkSize, int scale)
    {
        float topLeftX = (chunkSize - 1) / -2f;
        float topLeftZ = (chunkSize - 1) / 2f;

        MeshData meshData = new MeshData(chunkSize, 3);
        int vertexIndex = 0;

        /************
         * Nastavení vertexu
         * *************/
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

                vertexIndex++;
            }
        }

        meshData.CreateMeshWithVertex();
        /************
         * Nastavení trianglu v submehy
         * *************/

        for (int i = 0; i < 4; i++)
        {
            meshData.newTriangles(i);
            vertexIndex = 0;

            for (int y = 0; y < chunkSize; y++)
            {
                for (int x = 0; x < chunkSize; x++)
                {

                    if (x == 0 && y > 0)
                    {
                        vertexIndex++;
                    }

                    if (x == chunkSize - 1 && y < chunkSize - 1)
                    {
                        vertexIndex++;
                    }

                    if (y == chunkSize - 1 && x < chunkSize - 1)
                    {
                        vertexIndex++;                 
                    }

                    if (y == chunkSize - 2 && x == chunkSize - 2 && i >= 2)
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + 2);
                        meshData.AddTriangle(vertexIndex, vertexIndex + 2, vertexIndex + chunkSize + 4 + x);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 4 + x, vertexIndex + chunkSize + 3 + x);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3 + x, vertexIndex + chunkSize + 2 + x);
                    }

                    else if (y == chunkSize - 2 && x == 0 && i == 3)
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 4);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 4, vertexIndex + chunkSize + 1);
                        meshData.AddTriangle(vertexIndex + chunkSize + 1, vertexIndex + chunkSize + 4, vertexIndex + chunkSize + 3);
                        meshData.AddTriangle(vertexIndex + chunkSize + 1, vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 2);
                    }

                    else if (x == chunkSize - 2 && y < chunkSize - 2 && i >= 1)
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + 1 + 1, vertexIndex + chunkSize + 3);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 2);
                        meshData.AddTriangle(vertexIndex + 1 + 1, vertexIndex, vertexIndex + 1);
                    }

                    else if (x == 0 && y < chunkSize - 1 && i == 3)
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 3);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 1);
                        meshData.AddTriangle(vertexIndex + chunkSize + 3, vertexIndex + chunkSize + 2, vertexIndex + chunkSize + 1);
                    }

                    else if (y == chunkSize - 2 && x < chunkSize - 1 &&  i >= 2)
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + 1, vertexIndex + chunkSize + 4 + x);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 4 + x, vertexIndex + chunkSize + 3 + x);
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 3 + x, vertexIndex + chunkSize + 2 + x);
                    }
                    else if (x < chunkSize - 1 && y == chunkSize - 2 && (i == 0  || i == 1))           
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 3 + x, vertexIndex + chunkSize + 2 + x);
                        meshData.AddTriangle(vertexIndex + chunkSize + 1 + 3 + x, vertexIndex, vertexIndex + 1);
                    }
                
                    else if (x < chunkSize - 1 && y < chunkSize - 1)
                    {
                        meshData.AddTriangle(vertexIndex, vertexIndex + chunkSize + 1 + 2, vertexIndex + chunkSize + 2);
                        meshData.AddTriangle(vertexIndex + chunkSize + 1 + 2, vertexIndex, vertexIndex + 1);
                    }

                    vertexIndex++;
                    Debug.Log(vertexIndex);
                }
            }
            
            meshData.SetTriangels();
        }

        return meshData.GetMesh();
    }
}

public class MeshData
{
    public Vector3[] vertices;
    public int[] triangles;
    public Vector2[] uvs;
    private Mesh mesh;
    private int meshIndex;
    private int meshWidth;

    int triangleIndex;

    public MeshData(int meshWidth, int maxIndex)
    {
        this.meshWidth = meshWidth;
        vertices = new Vector3[meshWidth * meshWidth + (meshWidth - 1) * 3];
        triangleIndex = 0;
    }

    public void newTriangles(int index)
    {
        Debug.Log((meshWidth - 1) * (meshWidth - 1) * 6 + (meshWidth - 1) * 3 * index);
        triangles = null;
        triangles = new int[(meshWidth - 1) * (meshWidth - 1) * 6 + (meshWidth  - 1) * 3 * 3];
        meshIndex = index;
        triangleIndex = 0;
  
    }

    public void CreateMeshWithVertex()
    {
        mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.subMeshCount = 4;
    }

    public void AddTriangle(int a, int b, int c)
    {
        triangles[triangleIndex] = a;
        triangles[triangleIndex + 1] = b;
        triangles[triangleIndex + 2] = c;
        triangleIndex += 3;
    }

    public void SetTriangels()
    { 
       
        mesh.SetTriangles(triangles, meshIndex);
    
    }

    public Mesh GetMesh()
    {
        mesh.RecalculateNormals();
        return mesh;
    }
}