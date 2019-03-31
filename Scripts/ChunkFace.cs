using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChunkFace
{
    private ChunkFace parentChunk;
    private ChunkFace[] chunkTree;

    private int chunkSize;
    private float scale;
    private float radius;

    private Vector3 position;
    private Vector4 positionToDraw;

    private Bounds bounds;

    public bool generated;

    private List<Vector4> positionsList = new List<Vector4>();
    private List<Vector4> directionList = new List<Vector4>();

    private Vector3 directionX;
    private Vector3 directionY;

    public ChunkFace(ChunkFace parent, Vector3 position, float scale, int chunkSize, Vector3 viewerPositon, Vector3 directionX, Vector3 directionY, float radius)
    {
        this.parentChunk = parent;
        this.position = position;
        this.scale = scale;
        this.chunkSize = chunkSize;

        this.directionX = directionX;
        this.directionY = directionY;
        this.radius += radius;

        generated = true;

      //  bounds = new Bounds(CalculePositionOfSphere(), new Vector3(1, 0, 1) * chunkSize * scale);
        bounds = new Bounds(CalculePositionOfSphere(), new Vector3(1, 0, 1) * scale);
        positionToDraw = new Vector4((position.x), (position.y), (position.z), scale);
        // this.position.y += radius;

        Update(viewerPositon);
    }

    private Vector3 CalculePositionOfSphere()
    {
        float x = position.x / radius;
        float y = position.y / radius;
        float z = position.z / radius;

        float dx = x * Mathf.Sqrt(1.0f - (y * y * 0.5f) - (z * z * 0.5f) + (y * y * z * z  / 3.0f));
        float dy = y * Mathf.Sqrt(1.0f - (z * z * 0.5f) - (x * x * 0.5f) + (z * z * x * x / 3.0f));
        float dz = z * Mathf.Sqrt(1.0f - (x * x * 0.5f) - (y * y * 0.5f) + (x * x * y * y / 3.0f));

        return new Vector3(dx, dy, dz) * radius;
    }

    public List<Vector4> Update(Vector3 viewerPositon)
    {
        var dist = Vector3.Distance(viewerPositon, bounds.ClosestPoint(viewerPositon));
      
        if (parentChunk != null)
        {
            var distParent = Vector3.Distance(viewerPositon, parentChunk.GetBounds().ClosestPoint(viewerPositon));

            if (distParent / 2 > parentChunk.GetScale() )
            {
                parentChunk.MergeChunk();
                return positionsList;
            }
        }

        if (scale * 2 > dist)
        {
            SubDivide(viewerPositon);
        }

        else
        {
            float tessellation = CalculeTessellatio(dist);
            Vector4 newDirection = new Vector4(directionX.x, directionX.y, directionX.z, tessellation);
            positionsList.Clear();
            directionList.Clear();
            positionsList.Add(positionToDraw);
            directionList.Add(newDirection);
        }

        return positionsList;
    }

    private float CalculeTessellatio(float distance)
    {
        return (distance * 100)/(4 * scale - scale) * 2 + 1;
    }

    public ChunkFace[] getChunkTree()
    {
        return chunkTree;
    }

    public Bounds GetBounds()
    {
        return bounds;
    }

    public float GetScale()
    {
        return scale;
    }

    public Vector4 GetPositionToDraw()
    {
        return positionToDraw;
    }

    public Vector3 GetPosition()
    {
        return position;
    }

    public ChunkFace GetParrent()
    {
        return parentChunk;
    }

    public List<Vector4> GetPositionList()
    {
        return positionsList;
    }

    public List<Vector4> GetDirectionList()
    {
        return directionList;
    }


    public void MergeChunk()
    {
        if (chunkTree == null)
            return;

        for (int i = 0; i < chunkTree.Length; i++)
        {
            chunkTree[i].MergeChunk();
        }

        chunkTree = null;

        positionsList.Clear();
        positionsList.Add(positionToDraw);
        directionList.Clear();
        directionList.Add(directionX);
    }

    public void SubDivide(Vector3 viewerPosition)
    {
        float newScale = scale * 0.5f;

        //Vector3 left = (directionX * scale * chunkSize / 4);
        Vector3 left = (directionX * scale / 4);
        //Vector3 forward = (directionY * scale * chunkSize / 4);
        Vector3 forward = (directionY * scale / 4);
        


        chunkTree = new ChunkFace[] {
                new ChunkFace(this, position - left + forward,  newScale, chunkSize, viewerPosition, directionX, directionY, radius),
                new ChunkFace(this, position + left + forward,  newScale, chunkSize, viewerPosition, directionX, directionY, radius),
                new ChunkFace(this, position - left - forward,  newScale, chunkSize, viewerPosition, directionX, directionY, radius),
                new ChunkFace(this, position + left - forward,  newScale, chunkSize, viewerPosition, directionX, directionY, radius)
        };

        positionsList.Clear();
        directionList.Clear();
        foreach (var chunk in chunkTree)
        {
            positionsList.AddRange(chunk.GetPositionList());
            directionList.AddRange(chunk.GetDirectionList());
        }
    }

    public bool GetGenerate()
    {
        return generated;
    }

    public void SetGenerated(bool isGenerate)
    {
        generated = isGenerate;
    }
}