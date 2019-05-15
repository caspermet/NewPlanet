using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class ChunkFace
{
    private ChunkFace parentChunk;
    public ChunkFace[] chunkTree;

    private int chunkSize;
    private float scale;
    public int level;

    private Vector3 position;
    private Vector3 oldPosition;
    private Vector4 positionToDraw;
    private Camera camera;

    private Bounds bounds;
    public bool generated;

    private List<Vector4> positionsList = new List<Vector4>();
    private List<Vector4> directionList = new List<Vector4>();

    private List<Vector4>[] positionsListArray = new List<Vector4>[4];
    private List<Vector4>[] directionListArray = new List<Vector4>[4];

    private Vector4 directionX;
    private Vector3 directionY;

    private Vector3 viewerPositon;

    private Vector3 normal;

    private bool isVisible;

    private int[] myDirection;

    private ChunkFace[] topLevelneighbor;

    private Vector3 stepLeft;
    private Vector3 stepUp;
    private Vector3[] steps;
    bool isMerge;

    private ChunkFace topNeighbor;
    private ChunkFace rightNeighbor;
    private ChunkFace bottomNeighbor;
    private ChunkFace leftNeighbor;

    public ChunkFace(ChunkFace parent, Vector3 position, float scale, Camera viewer, Vector4 directionX, Vector3 directionY, bool isVisible, int level, int[] myDirection)
    {
        initialization(parent, position, scale, viewer, directionX, directionY, isVisible, level, myDirection);
    }

    private void initialization(ChunkFace parent, Vector3 position, float scale, Camera viewer, Vector4 directionX, Vector3 directionY, bool isVisible, int level, int[] myDirection)
    {

        this.parentChunk = parent;
        this.position = position;
        this.oldPosition = position;
        this.scale = scale;

        this.directionX = directionX;
        this.directionY = directionY;
        this.camera = viewer;
        this.level = level;
        this.myDirection = myDirection;
        isMerge = false;
        this.isVisible = isVisible;
        chunkTree = null;
        InitLists();
        generated = true;

        Vector3 newPosition = CalculePositionOfSphere(position);
        bounds = new Bounds(newPosition, newPosition.normalized * scale);
        positionToDraw = new Vector4((position.x), (position.y), (position.z), scale);

        RecalculSteps();

        Update(viewer.transform.position, isVisible, position, scale);
    }

    private void InitLists()
    {
        for (int i = 0; i < 4; i++)
        {
            positionsListArray[i] = new List<Vector4>();
            directionListArray[i] = new List<Vector4>();
        }
    }

    private Vector3 CalculePositionOfSphere(Vector3 position)
    {
        float x = position.x / PlanetData.PlanetRadius;
        float y = position.y / PlanetData.PlanetRadius;
        float z = position.z / PlanetData.PlanetRadius;

        float dx = x * Mathf.Sqrt(1.0f - (y * y * 0.5f) - (z * z * 0.5f) + (y * y * z * z / 3.0f));
        float dy = y * Mathf.Sqrt(1.0f - (z * z * 0.5f) - (x * x * 0.5f) + (z * z * x * x / 3.0f));
        float dz = z * Mathf.Sqrt(1.0f - (x * x * 0.5f) - (y * y * 0.5f) + (x * x * y * y / 3.0f));

        return new Vector3(dx, dy, dz) * PlanetData.PlanetRadius;
    }

    public void Update(Vector3 viewerPositon, bool isStillVisible, Vector3 positionA, float newScale)
    {

        if (positionA != position)
        {
            scale = newScale;
            position = positionA;
            Vector3 newPosition = CalculePositionOfSphere(positionA);
            bounds.center = newPosition;
            bounds.size = (new Vector3(1, 1, 1) - newPosition.normalized) * scale;
            RecalculSteps();

            positionToDraw = new Vector4((position.x), (position.y), (position.z), scale);
        }


        if (isStillVisible)
        {
            isVisible = FrustumCulling.Frustum(camera, bounds.center, scale * 0.5f, bounds);
        }

        if (!isVisible)
        {
            return;
        }

        var dist = Vector3.Distance(viewerPositon, bounds.ClosestPoint(viewerPositon));
        this.viewerPositon = viewerPositon;

        if (parentChunk != null)
        {
            var distParent = Vector3.Distance(viewerPositon, parentChunk.GetBounds().ClosestPoint(viewerPositon));

            if (distParent / 2 > parentChunk.GetScale())
            {

                parentChunk.MergeChunk();
                isMerge = true;
                return;
            }

        }

        if (chunkTree != null)
        {
            int i = 0;
            foreach (var item in chunkTree)
            {
                item.Update(viewerPositon, isVisible, steps[i], scale * 0.5f);
                i++;

            }

        }
        else if (scale * 2 > dist)
        {
            SubDivide(viewerPositon);
        }
        else
        {
            isVisible = FrustumCulling.horizont(camera, bounds.center);
        }

        return;
    }

    private void RecalculSteps()
    {
        stepLeft = (new Vector3(directionX.x, directionX.y, directionX.z) * scale / 4);
        stepUp = (directionY * scale / 4);
        steps = null;
        steps = new Vector3[]
        {
            position - stepLeft + stepUp,
            position + stepLeft + stepUp,
            position - stepLeft - stepUp,
            position + stepLeft - stepUp
        };
    }

    public void GetPosition2()
    {
        ClearPositionAndDirection();
        Vector4 newDirection = new Vector4(directionX.x + directionY.x, directionX.y + directionY.y, directionX.z + directionY.z, directionX.w);
        Vector4 edge;

        int rotate;
        edge = FindEnge2();



        int suma = (int)(edge.x + edge.y + edge.z + edge.w);
        rotate = CalculateRotation.CalculateRotateOfMesh(edge, suma);

        newDirection.w += rotate;
        if (suma > 3)
        {
            suma = 3;
        }

        positionsListArray[suma].Add(positionToDraw);
        directionListArray[suma].Add(newDirection);

        if (edge.x == 1 || edge.y == 1 || edge.z == 1 || edge.w == 1)
        {
            positionsListArray[suma].Add(positionToDraw);
            directionListArray[suma].Add(newDirection);
        }
        else
        {
            positionsListArray[0].Add(positionToDraw);
            directionListArray[0].Add(newDirection);
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

    public Vector4 FindEnge2()
    {
        float right = 0;
        float left = 0;
        float bottom = 0;
        float top = 0;


        top = topNeighbor == null ? 0 : topNeighbor.IsHasChild();
        right = rightNeighbor == null ? 0 : rightNeighbor.IsHasChild();
        bottom = bottomNeighbor == null ? 0 : bottomNeighbor.IsHasChild();
        left = leftNeighbor == null ? 0 : leftNeighbor.IsHasChild();

        return new Vector4(right, bottom, left, top);
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

    public List<Vector4>[] findDirection()
    {
        return directionListArray;
    }

    public List<Vector4>[] findAllChunkToDraw()
    {
        ClearPositionAndDirection();
        if (!isVisible)
        {
            return null;
        }

        if (chunkTree == null)
        {
            ClearPositionAndDirection();
            GetPosition2();

            return positionsListArray;
        }
        else
        {
            chunkTree[0].UpdateNeighbor(topNeighbor, chunkTree[1], chunkTree[2], leftNeighbor);
            chunkTree[1].UpdateNeighbor(topNeighbor, rightNeighbor, chunkTree[3], chunkTree[0]);
            chunkTree[2].UpdateNeighbor(chunkTree[0], chunkTree[3], bottomNeighbor, leftNeighbor);
            chunkTree[3].UpdateNeighbor(chunkTree[1], rightNeighbor, bottomNeighbor, chunkTree[2]);

            ClearPositionAndDirection();

            foreach (var chunk in chunkTree)
            {

                List<Vector4>[] pom = chunk.findAllChunkToDraw();
                List<Vector4>[] pomDir = chunk.findDirection();

                if (pom == null)
                {
                    continue;
                }

                for (int i = 0; i < 4; i++)
                {
                    positionsListArray[i].AddRange(pom[i]);
                    directionListArray[i].AddRange(pomDir[i]);
                }
            }
        }

        return positionsListArray;
    }

    public float IsHasChild()
    {
        if (chunkTree != null)
        {
            return 1;
        }
        return 0;
    }

    public void MergeChunk()
    {
        if (chunkTree == null)
            return;

        for (int i = 0; i < 4; i++)
        {
            chunkTree[i].MergeChunk();
        }

        chunkTree = null;
        ClearPositionAndDirection();
    }

    public void UpdateTopNeighbor(ChunkFace[] topLevelneighbor)
    {
        this.topLevelneighbor = topLevelneighbor;
        topNeighbor = topLevelneighbor[0];
        rightNeighbor = topLevelneighbor[1];
        bottomNeighbor = topLevelneighbor[2];
        leftNeighbor = topLevelneighbor[3];

    }

    public void UpdateNeighbor(ChunkFace top, ChunkFace right, ChunkFace bottom, ChunkFace left)
    {
        if (top == null)
        {
            topNeighbor = null;
        }
        else if (top.level == level)
        {
            topNeighbor = top;
        }
        else if (top.chunkTree != null)
        {
            float distance = 0;
            float oldDistance = 0;
            int index = 0;
            for (int i = 0; i < 4; i++)
            {
                oldDistance = Vector3.Distance(bounds.center, top.chunkTree[i].bounds.center);
                if (i == 0 || oldDistance < distance)
                {
                    distance = oldDistance;
                    index = i;
                }
            }

            topNeighbor = top.chunkTree[index];
        }
        else
        {
            topNeighbor = null;
        }

        if (right == null)
        {
            rightNeighbor = null;
        }
        else if (right.level == level)
        {
            rightNeighbor = right;
        }
        else if (right.chunkTree != null)
        {
            float distance = 0;
            float oldDistance = 0;
            int index = 0;
            for (int i = 0; i < 4; i++)
            {
                oldDistance = Vector3.Distance(bounds.center, right.chunkTree[i].bounds.center);
                if (i == 0 || oldDistance <= distance)
                {
                    distance = oldDistance;
                    index = i;
                }
            }

            rightNeighbor = right.chunkTree[index];
        }
        else
        {
            rightNeighbor = null;
        }

        if (bottom == null)
        {
            bottomNeighbor = null;
        }
        else if (bottom.level == level)
        {
            bottomNeighbor = bottom;
        }
        else if (bottom.chunkTree != null)
        {
            float distance = 0;
            float oldDistance = 0;
            int index = 0;
            for (int i = 0; i < 4; i++)
            {
                oldDistance = Vector3.Distance(bounds.center, bottom.chunkTree[i].bounds.center);
                if (i == 0 || oldDistance < distance)
                {
                    distance = oldDistance;
                    index = i;
                }
            }

            bottomNeighbor = bottom.chunkTree[index];
        }
        else
        {
            bottomNeighbor = null;
        }

        if (left == null)
        {
            leftNeighbor = null;
        }

        else if (left.level == level)
        {
            leftNeighbor = left;
        }
        else if (left.chunkTree != null)
        {
            float distance = 0;
            float oldDistance = 0;
            int index = 0;
            for (int i = 0; i < 4; i++)
            {
                oldDistance = Vector3.Distance(bounds.center, left.chunkTree[i].bounds.center);
                if (i == 0 || oldDistance < distance)
                {
                    distance = oldDistance;
                    index = i;
                }
            }

            leftNeighbor = left.chunkTree[index];
        }
        else
        {
            leftNeighbor = null;
        }
    }

    public void SubDivide(Vector3 viewerPosition)
    {
        float newScale = scale * 0.5f;

        chunkTree = new ChunkFace[] {
                new ChunkFace(this, position - stepLeft  + stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {0,0 }),
                new ChunkFace(this, position + stepLeft + stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {0,1}),
                new ChunkFace(this, position - stepLeft - stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {1,0}),
                new ChunkFace(this, position + stepLeft - stepUp,  newScale, camera, directionX, directionY, isVisible, level + 1, new int[] {1,1})
            };
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