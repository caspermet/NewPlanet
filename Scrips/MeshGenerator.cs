using UnityEngine;
using System.Collections;

public static class MeshGenerator
{

    public static MeshData GenerateTerrainMesh(int chunkSize, int scale)
    {
        float topLeftX = (chunkSize - 1) / -2f;
        float topLeftZ = (chunkSize - 1) / 2f;

        MeshData meshData = new MeshData(chunkSize, chunkSize);
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
}

public class MeshData
{
    public Vector3[] vertices;
    public int[] triangles;
    public Vector2[] uvs;

    private Mesh mesh;

    int triangleIndex;

    public MeshData(int meshWidth, int meshHeight)
    {
        vertices = new Vector3[meshWidth * meshHeight];
        uvs = new Vector2[meshWidth * meshHeight];
        triangles = new int[(meshWidth - 1) * (meshHeight - 1) * 6];
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
        mesh = new Mesh();
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        mesh.uv = uvs;
        mesh.RecalculateNormals();

    }

    public Mesh GetMesh()
    {
        return mesh;
    }

}